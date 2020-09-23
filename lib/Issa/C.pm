package Issa::C;
# транслятор с Иссы на С

use base Issa;

use strict;
use warnings FATAL => "all";

use DDP {colored => 1};

# $_ = [lex, ...]
# @_ = (lex, ...)
my %morph = (
	default => sub { $_->dator->err("Нет морфера " . ($_->rule // $_->lex), $_) },
	int => sub {$_->s},
	num => sub {$_->s},
	str => sub {$_->s},
	# все операторы
	OP => sub {
		my ($x, $op, $y) = @_;
		"($x->{S} $op->{S} $y->{S})"
	},
	#FILE => sub {  },
);

# конструктор
sub new {
	my $cls = shift;
	$cls->SUPER::new(
		morph => \%morph,
		@_
	)
}

# запускает внешнюю программу
sub sys($) {
	my ($s) = @_;
	print "$s\n";
	system $s and die $s
}

# меняет расширение файла на .c
sub c_file {
	my ($self) = @_;
	local $_=$self->file; s!(\.[^\.]*)?$!.c!; $_
}

# удаляет расширение
sub elf_file {
	my ($self) = @_;
	local $_=$self->file; s!(\.[^\.]*)?$!!; $_
}

# компиллирует в С
sub compile {
	my ($self, $from_file) = @_;
	my $compiller = $self->clone(file => $from_file);
	my $code = $compiller->translate;
	
	my $c_file = $self->c_file;
	
	open my $f, ">", $c_file or die "не могу записать в $c_file: $!";
	print $f $code;
	close $f;
	
	$self
}

# компиллирует, собирает и запускает
sub run {
	my ($self, $file) = @_;
	$self->compile($file)->build;
	sys "./" . $self->elf_file;
	$self
}

# собирает
sub build {
	my ($self, $c_file, $exef) = @_;
	my $elf_file = $self->elf_file;
	my $c_file = $self->c_file;
	sys "gcc -fdiagnostics-color=always -fextended-identifiers -o $elf_file $c_file";
	$self
}

# сохраняет в файл, запускает и возвращает ответ в виде строки
sub val {
	my ($self, $code) = @_;
	my $file = ".val.iss";
	open my $f, ">", ".val.iss" or die $!;
	print $f "    $code";
	close $f;
	$self->compile($file)->build;
	my $elf_file = $self->elf_file;
	`./$elf_file`
}

1;