package Issa;
# язык программирования Исса. Парсер

use base Dator;

use strict;
use warnings FATAL => "all";
use DDP {colored => 1};


my %BRACE = (
	"(" => ")",
	"[" => "]",
	"{" => "}",
	"ident_begin" => "ident_end",
	"new" => ")",
	"fn" => ")",
);
my %UNBRACE = reverse %BRACE;

sub is_atom { $_[0] =~ /^(int|num|str|var)\z/n }
sub is_open { $BRACE{$_[0]} }
sub is_close { $UNBRACE{$_[0]} }

my $issa = Dator->new(
	re => qr{
		(?<remark> ^\S [^\n]* $ ) |
		(?<empty> ^ [\t\ ]* $ ) |
		(?<rem> (?<= [\ \t] ) \# [\ \t] [^\n]* $ ) |
		(?<ident> ^[\ \t]+ ) |
		(?<space> [\ \t]+) |
		(?<nl> \n) |
		(?<num> \d+\.\d+ ) |
		(?<int> \d+ ) |
		(?<str> " ( \\" | [^"] )* " ) |
		(?<str> ' ( \\' | [^'] )* ' ) |
		(?<var> \b \pL \b ) |
		(?<fn> \b [\p{Lowercase_Letter}_] \w+ ) \( |
		(?<method> \b [\p{Lowercase_Letter}_] \w+ ) |
		(?<new> \b \p{Uppercase_Letter} \w+ ) \( |
		(?<class> \b \p{Uppercase_Letter} \w+ ) |
		(?<brace> [()\[\]{}] ) |
		(?<op> [\p{Punctuation}\p{Symbol}]+ ) |
		(?<mistic> .)
	}xms,
	# 2-й проход. Список лексем уже есть
	map => {
		# пропускаем без изменений
		default => sub { $_->dator->err("Нет маппера " . $_->lex, $_) },
		# комментарии
		remark => sub { $_->dator->{ctx}{remark}{$_->lineno} = $_; () },
		rem => sub { $_->dator->{ctx}{remark}{$_->lineno} = $_; () },
		empty => sub { $_->dator->{ctx}{remark}{$_->lineno} = $_; () },
		# добавляем скобки по отступам
		ident => sub {
			my $lvl = $_->s;
			$lvl =~ s/\t/  " " x 4  /ge;
			$lvl = length $lvl;
			
			my $lvl_st = $_->dator->{ctx}{level_st} //= [$lvl];
			my $level = $lvl_st->[$#$lvl_st];
			my @lex;

			p my $x={lvl=>$lvl, lvl_st=>$lvl_st};
			
			print $_->line, "\n";
			
			push(@$lvl_st, $lvl), push @lex, $_->clone(lex => "ident_begin") if $lvl > $level;
		
			if($lvl < $level) {

				while() {
					my $i = $lvl_st->[$#$lvl_st];
					$lvl = $i, last if $i == $lvl;
					pop @$lvl_st;
					$_->dator->err("Нарушен отступ", $_) if !defined $i;
					push @lex, $_->clone(lex => "ident_end");
				}
			}

			push @lex, $_->clone(lex => "newline") if $lvl == $level && $_->prev && $_->next;
			@lex
		},
		# отбрасываем пробелы
		space => sub { $_->s; () },
		# отбрасываем символ новой строки
		nl => sub { $_->s; () },
		#num => sub {$_},
		int => sub { $_->{class} = $_->dator->class("I32"); $_},
		#str => sub {$_},
		new => sub { $_->{class} = $_->dator->class($_->s); $_},
		class => sub { $_->{class} = $_->dator->class("Class"); $_},
		
		# переставляем операторы
		op => sub {
			$_->{rule} = "method";
			
			my $p = $_->prev->lex;
			my $n = $_->next? $_->next->lex: '$';
			
			# пунктуация
			if($_->lex =~ /^[;,]$/n) { $_ }
			# space     a + a      	space
			# a|}   	a+a			a|{
			elsif($p eq "space" and $n eq "space") { $_->{lex} = "A$_->{s}B"; $_ }
			elsif(is_atom($p) || is_close($p) and is_atom($n) || is_open($n)) { $_->clone(lex => "a$_->{s}b") }
			# space|^|{ +a  {|a
			elsif($p =~ /^(space|ident)\z/n || is_open($p) and is_atom($n) || is_open($n)) { $_->clone(lex => "$_->{s}a") }
			# a|}|method a+  space|}|$
			elsif(is_atom($p) || is_close($p) || $p eq "method" and $n eq "space" || is_close($n) || $n eq "nl" || $n eq '$') { $_->clone(lex => "a$_->{s}") }
			else { $_->dator->err("Оператор `$_->{s}` не позиционирован", $_) }
		},
		# определяем, является ли метод унарным и если да, то вставляем фейковый
		method => sub {
			$_->{rule} = "method";
		
			# a method [space] }|method|nl|$
			my $next = $_->next;
			my $n = !$next? '$': $next->lex eq "space"? ($next->next? $next->next->lex: '$'): $next->lex;
			
			is_close($n) || $n =~ /^(method|nl|\$)\z/? $_->clone(lex => "umethod"): $_
		},
		# ругаемся на левый символ
		mistic => sub {	$_->dator->err(sprintf("мистический символ %s#%i", 
			$_->s, ord $_->s), $_) },
	},
	# 3-й проход. Пары открывающих-закрывающих скобок
	braces => {%BRACE},
	# 4-й проход. Операторы
	op => do {
	
		local $_ = "
			;
			method
			
			A||B
			A&&B
			
			A<B		A>B		A<>B	A=B		A==B
			
			A+B		A-B
			A*B		A/B		A%B
			A^B
			
			,
			umethod
			
			a||b
			a&&b
			!a
			
			a<b		a>b    a<>b      a=b     a==b
			
			a+b		a-b
			a*b		a/b		a%b
			a^b
			a%		a\$		a#
			-a
		";
	
		my @lines = grep { !/^\s*$/ } split /[ \t]*\n[ \t]*/;

		my $prio = @lines;
		+{ map {
			$prio--;
			map {(
				$_ => [$prio,
					/method/? Dator->xfy:
					/umethod/? Dator->yf:
					/^[;,]$/? Dator->xfy:
					/^a.+b$/i? Dator->xfy:
					/^b.+a$/i? Dator->yfx:
					/^a.+a$/i? Dator->xfx:
					/^.+a$/i? Dator->fy:
					/^.+b$/i? Dator->fx:
					/^a.+$/i? Dator->yf:
					/^b.+$/i? Dator->xf:
					die "Непонятный оператор $_"
				]
			)} grep { !/^\s*$/ } split /\s+/
		} @lines }
	},
	# вывод типов
	morph => {
		int => sub {"I32"},
		
		default => sub { $_->dator->err("Не определён операнд " . $_->cc, $_) },
	},
	stash => {
		# class => impl => method => AST
		class => {
			Nil => {
				has => {
					name => "Nil",
				},
			},
			Class => {
				super => "Nil",
				name => "Class",
				impl => {
					subclass => sub {
						my ($s, $c) = @_;
						my $super = $s->dator->{stash}{class}->{$s->s};
						my $class = $s->dator->{stash}{class}->{$c->s};
						$s->err("Нет класса $s->{s}") if !$super;
						#$c->err("Класс $c->{s} уже есть!") if $class;
						
						# расширена таблица виртуальных функций
						$class->{impl}->{$_} = $super->{impl}->{$_} for keys %{$super->{impl}};
						return {s=>""};
					},
					has => sub {
						my ($c, $has) = @_;
						
					},
					impl => sub {
						my ($c, $has) = @_;
					},
				},
			},
		},
	},
);

$issa->{INC} = ["Barsum"];
$issa->{file} = "barsum.iss";

bless($issa, __PACKAGE__);

{
	local $issa->{noload} = 1;
	$issa->translate;
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ МЕТОДЫ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# конструктор
sub new {
	my $cls = shift;
	bless {
		%$issa,
		file => "?.iss",
		@_
	}, ref $cls || $cls;	
}

# Добавляет перед строкой \t
sub val {
	my ($self, $s) = @_;
	my $root = $self->translate("\t$s")->{tree};
	
	$root->calc
}

# возвращает класс. Если надо - то подгружает его. 
# При этом путь к файлу становится: Admin_LingUserModel -> model/user/admin-ling.iss
sub class {
	my ($self, $class) = @_;
	
	return $self->{stash}{class}{$class} //= {name => $class} if $issa->{noload};
	
	return $self->{stash}{class}{$class} if exists $self->{stash}{class}{$class};
	
	my $path = $class;
	$path =~ s!(_)?(\p{Uppercase_Letter})!($1? "-": "/") . lc $2!ge;
	$path = (join "/", reverse split m!/!, $path) . ".iss";
	
	my $x = $self->clone(file=>$path);
	$x->translate;
	$x
}

# # обходит
# sub compile {
	# my ($self) = @_;
	# $self->translate;
	# $self->calc
# }

1;