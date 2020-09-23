package Dator::Lex;
# модуль

use strict;
use warnings FATAL=>"all";

use v5.10;
use experimental 'smartmatch';
no warnings 'experimental::smartmatch';

use DDP {colored => 1};
use Term::ANSIColor qw/colored color/;


# конструктор
sub new {
	my $cls = shift;
	my $self = bless {@_}, ref $cls || $cls;
	
	die "lineno=$self->{lineno}" if $self->{lineno} < 1;
	die "charno=$self->{charno}" if $self->{charno} < 1;
	
	die "dator is ".(ref $self->{dator}? "ref ": "string "). ($self->{dator} // "<undef>") unless ref $self->{dator} eq "Dator" || UNIVERSAL::isa($self->{dator}, "Dator");
	
	$self
}

sub _prev {
	my $i=$_[0]->{dator}{i}; 
	die "нет dator->i" if !defined $i;
	my $lex = $_[0]->{dator}{lex};
	$i+=$_[1];
	$i<0 || $i>=@$lex? undef: $lex->[$i]
}

sub prev { $_[0]->_prev(-1) }
sub next { $_[0]->_prev(1) }

sub lineno { $_[0]->{lineno} }
sub charno { $_[0]->{charno} }
sub lex { $_[0]->{lex} }
sub s { $_[0]->{s} }
sub S { $_[0]->{S} }
sub dator { $_[0]->{dator} }
sub file { $_[0]->{dator}->{file} }

sub tree { $_[0]->{tree} }	# список лексем в скобках
sub operands { $_[0]->{operands} }	# операнды оператора
sub operand { $_[0]->{operand} }	# операнд внутри скобок

# f[a+b]         [ operand +  operands f

sub close_brace { $_[0]->{close_brace} }
sub is_open { $_[0]->{is_open} }
sub is_close { $_[0]->{is_close} }


sub is_atom { my ($self) = @_; !exists $self->dator->op->{$self->lex} }
sub is_op { my ($self) = @_; exists $self->dator->op->{$self->lex} }
sub typeop { my ($self) = @_; $self->is_op? $self->dator->op->{$self->lex}->[1]: die "Тип оператора запрашивается у атома" }
sub prio { my ($self) = @_; $self->is_op? $self->dator->op->{$self->lex}->[0]: die "Приоритет оператора запрашивается у атома" }

sub is_binary {	my ($self) = @_; $self->is_op && $self->typeop ~~ [$self->dator->xfx, $self->dator->xfy, $self->dator->yfx] }
sub is_unary { my ($self) = @_; !$self->is_binary }
sub is_left_unary { my ($self) = @_; $self->typeop ~~ [$self->dator->fx, $self->dator->fy] }
sub is_right_unary { my ($self) = @_; $self->typeop ~~ [$self->dator->xf, $self->dator->yf] }
sub is_nonassoc { my ($self) = @_; $self->typeop ~~ [$self->dator->xfx, $self->dator->xf, $self->dator->fx] }
sub is_leftassoc { my ($self) = @_; $self->typeop ~~ [$self->dator->xfy, $self->dator->yf] }
sub is_rightassoc { my ($self) = @_; $self->typeop ~~ [$self->dator->yfx, $self->dator->fy] }


# клонирует
sub clone {
	my $self = shift;
	$self->new(%$self, @_)
}

# строка с созицией
sub line_pos {
	my ($self) = @_;

	my $line = $self->line;
	my $s = " " x ($self->{charno}-1);
	
	"$line\n$s".colored( "^", "blue")."\n"
}

sub _color_line {
	my ($line) = @_;
	$line =~ s!
		(?<int> \d+ ) |
		(?<sym> \p{Symbol}+ ) |
		(?<punct> \p{Punctuation}+ )
	!
		exists $+{int}? colored($&, "blue"):
		exists $+{sym}? colored($&, "red"):
		exists $+{punct}? colored($&, "white"): ()
		
	!gex;
	$line
}

# колоризированная строка
sub line {
	my ($self) = @_;
	my $line = $self->dator->{lines}[$self->lineno-1];
	my $ch = $self->{charno}-1;
	my($x, $c, $y) = $line =~ /^(.{$ch})(.)(.*)\z/s;
	_color_line($x) . colored($c, "on_white blue") . _color_line($y)
}

# колоризированная лексема
sub cc {
	my ($lex) = @_;
	join "", ($lex->{rule}? colored("$lex->{rule}!", "yellow"): ()),
			($lex->{lex} eq $lex->{s}? colored("`$lex->{s}`", "on_cyan red"): 
				(colored($lex->{lex}, "magenta"),
					colored("#", "bold black"),
						colored("`$lex->{s}`", "cyan")));
}


# проброс	
sub err {
	my ($self, $err) = @_;
	$self->dator->err($err, $self);
}

# проброс	
sub stash {
	my ($self) = @_;
	$self->dator->{stash}
}




1;