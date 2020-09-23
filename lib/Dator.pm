package Dator;
# парсер

#use common::sense;
use strict;
use warnings FATAL => qw/all/;

use Dator::Lex;
use Scalar::Util qw//;
use Term::ANSIColor qw/colored color/;
use DDP {colored=>1};
use Carp;
$SIG{__DIE__} = sub { die Carp::longmess @_ };

# конструктор
sub new {
	my ($cls, %o) = @_;
	my $self = bless {
		stash=>{}, # для всех файлов - один 
		ctx=>"Не использовать вне translate!",	# отдельный для каждого файла
		INC => ["."],
	}, ref $cls || $cls;
	$self->{$_} = delete $o{$_} for qw/file re map braces op morph stash/;
	die "неизвестный параметер: " . join ", ", keys %o if keys %o;
	$self
}

# список лексем
sub ncc (@) {
	join " ", map { $_->cc } @_
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Свойства ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

sub file {
	my ($self, $f) = @_;
	@_==1? $self->{file}: do { $self->{file}=$f; $self }
}

sub op {
	my ($self) = @_;
	$self->{op}
}

# контекст, используется для локальных свойств компилляторов. Доступен только для текущего файла
sub ctx {
	my ($self) = @_;
	$self->{ctx}
}

# сташ - один для всех файлов
sub stash {
	my ($self) = @_;
	$self->{stash}
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Компилляция ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# лексический анализ
sub lexanalyze {
	my ($self, $code) = @_;
	
	$code //= do {
		my $file;
		for my $inc ( @{$self->{INC}} ) {
			$file = "$inc/$self->{file}";
			last if -e $file;
		}
		
		die "Нет файла $file в INC: " . join ", ", @{$self->{INC}} if !$file;
		
		open my $f, "<", $file or die "не могу открыть `$file`: $!";
		my $x = join "", <$f>;
		close $f;
		$self->{INC_FILE}{$self->{file}} = $file;
		$x
	};

	my @lines;	# позиции \n
	while($code =~ /\n/g) { push @lines, length $` }
	push @lines, length($code)-1 if $code !~ /\n\z/;

	print "`$code`\n";

	$self->{lex} = my $lex = [];
	my $lineno = 0;
	while($code =~ /$self->{re}/g) {
		my ($k, $v) = %+;
		my $pos = length $`;
		while($lineno<@lines && $lines[$lineno]<$pos) {$lineno++}
		
		push @$lex, my $x=Dator::Lex->new(lex=>$k, s=>$v, lineno=>$lineno+1, 
			charno => $lineno==0? $pos+1: $pos-$lines[$lineno-1],
			dator => $self);
	}
	
	$self->{lines} = [split /\n/, $code];
	
	$self
}

# фильтр для лексем
sub map {
	my ($self) = @_;
	my $default = $self->{map}->{default} //= sub { $_ };
	$self->{i} = -1;
	print "map\n";
	@{$self->{lex}} = map {
		$self->{i}++;
		my $lex = $_;
		#print "RUN ", $self->{map}->{$lex->{lex}}? $lex->{lex}: "default", "\n";
		map {
			#print "`$_`\n";
			$self->err("map ".($self->{map}->{$lex->{lex}}? $lex->{lex}: "default")." вернул не Dator::Lex, а `$_`", $lex) if !UNIVERSAL::isa($_, "Dator::Lex");
			$_
		} ($self->{map}->{$_->{lex}} // $default)->() } @{$self->{lex}};
	delete $self->{i};
	$self
}

# превращаем в дерево
sub partition {
	my ($self) = @_;
	my $braces = $self->{braces};
	my %unbraces = reverse %$braces;
	my $node = $self->{tree} = Dator::Lex->new(lex=>"FILE", lineno=>1, charno=>1, dator=>$self, s=>"");
	$self->{lex_braces} = [$node];
	my @S;
	
	for my $lex (@{$self->{lex}}) {
		if($unbraces{$lex->{lex}}) {
			$self->err("Закрывающая скобка `$lex->{lex}` без открывающей", $lex) if !exists $braces->{$node->{lex}};
			$self->err("Скобка `$node->{lex}` закрыта `$lex->{lex}`", $lex) if $braces->{$node->{lex}} ne $lex->{lex};
			$node->{close_brace} = $lex;
			$node->{is_open} = 1;
			$lex->{is_close} = 1;
			$self->err("Закрывающая скобка `$node->{lex}` без открывающей", $node) if !@S;
			$node = pop @S;
			next;
		}
		#Scalar::Util::weaken($lex->{parent} = $node);
		push @{$node->{tree}}, $lex;
		push(@{$self->{lex_braces}}, $lex), push(@S, $node), $node = $lex if $braces->{$lex->{lex}};
	}
	
	$self->err("Остались скобки: " . join(", ", map {$_->lex} $node, @S), $node) if @S;
	
	$self
}


sub xfx {1}
sub xfy {2}
sub yfx {3}
sub xf {4}
sub fx {5}
sub yf {6}
sub fy {7}

#sub asc (&@) { my $sub = shift; local $_; sort { $_=$a; my $x=$sub->(); $_=$b; $x<=>$sub->() } @_ }

# ранжирование операторов внутри скобок
sub _rank {
	my ($self, $brace) = @_;
	
	$self->err("Пустые скобки", $brace) if !@{$brace->{tree}};
	
	my @S; my @T;
	
	my $pop_op = sub {
		my $op = pop @S;
		if($op->is_binary) {
			$self->err("Не хватает операндов для оператора " . $op->lex, $op) if @T < 2;
			$op->{operands} = [reverse pop(@T), pop @T];
		} else {
			$self->err("Нет операнда для оператора " . $op->lex, $op) if !@T;
			$op->{operands} = [pop @T];
		}
		push @T, $op;
	};
	
	for my $e ( @{$brace->{tree}} ) {
	
		if( $e->is_atom ) { push @T, $e }
		else {
			my $prio = $e->prio;
			
			if($e->is_nonassoc) {
				while(@S && (my $prio2=$S[$#S]->prio) <= $prio) { 
					$self->err("Неассоциативный оператор " . $e->lex . " в одном ряду с оператором " . $S[$#S]->lex, $e) if $prio2==$prio && $S[$#S]->is_nonassoc;
					$pop_op->() }
			} elsif($e->is_leftassoc) {
				while(@S && $S[$#S]->prio <= $prio) { $pop_op->() }
			} else {
				while(@S && $S[$#S]->prio < $prio) { $pop_op->() }
			}
			push @S, $e;
			
			if($e->is_right_unary) { $pop_op->() }
		}
	}
	
	while(@S) { $pop_op->() }
	
	$self->err("Остались операнды " . join(", ", map { $_->lex } @T), $T[$#T]) if @T!=1;
	
	$brace->{operand} = $T[0];
		
	$self
}

# ранжирование в соответствии с приоритетом и ассоциативностью операторов
# ранжирование производится в скобках
sub rank {
	my ($self) = @_;
	
	$self->_rank($_) for @{$self->{lex_braces}};
	
	$self
}

# собираем
sub _morph {
	my ($self) = @_;

	# скобки могут быть одновременно операторами
	
	if($_->{operand}) {
		push @{$self->{path}}, $_;
		my $operand = $_->{operand};
		{
			local $_ = $operand;
			$self->_morph;
		};
		pop @{$self->{path}};
	}

	if($_->{operands}) {
		push @{$self->{path}}, $_;
		$self->_morph for @{$_->{operands}};
		pop @{$self->{path}};
	}

	$_->{S} = ($self->{morph}{ $_->{rule} // $_->{lex} } // $self->{morph}{default})->();
}

# транслируем
sub morph {
	my ($self, $morph) = @_;
	
	$self->{morph} = $morph, return $self if @_ == 2;
	
	local $self->{path} = [];
	local $_ = $self->{tree};
	$self->_morph
}

# печать
sub xprint {
	my ($self) = @_;
	
	#local $self->{tree} = $lex if $lex;
	local $self->{morph} = {
		default => sub { 
			join "",
				$_->cc,
				$_->{operands}? (
					colored("[ ", "red"),
						(join " ", map { $_->{S} } @{$_->{operands}}),
					colored(" ]", "red"),
				): (),
				$_->{operand}? (
					colored("{ ", "red"),
						$_->{operand}{S},
					colored(" }", "red"),
				): ()
		},
	};
	
	print $self->morph, "\n";
	
	$self
}

# компиллирует код
sub translate {
	my ($self, $code) = @_;
	$self->{ctx} = {};
	$self->lexanalyze($code)->map->partition->rank->morph
}

# рассуждения: вычисление дерева AST
sub reasoning {
	my ($self) = @_;
	$self
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Утилиты ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# выбрасывает ошибку
sub err {
	my ($self, $err, $lex) = @_;
	die "В err передан не Dator::Lex, а `".($lex // "<undef>")."`" if !UNIVERSAL::isa($lex, "Dator::Lex");
	die sprintf "%s:%s %s\n%s", $self->{file}, $lex->lineno, $err, $lex->line_pos;
}

# Клонировать
sub clone {
	my $self = shift;
	bless {%$self, @_}, ref $self
}

1;