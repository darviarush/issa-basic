use common::sense;

my $bin = $ARGV[0];
compile_method($ARGV[1]);

my %method;	# методы
my $lineno;
my $charno;


sub readfile {
	my ($s) = @_;
	open my $f, "<", $s or die "open < `$s`: $!";
	read $f, my $buf, -s $f;
	close $f;
	$buf
}

sub writefile {
	my ($s, $m) = @_;
	open my $f, ">", $s or die "open > `$s`: $!";
	print $f $m;
	close $f;
}


sub err {
	print STDERR "$lineno:$charno @_\n";
	exit 1;
}

sub compile_method {
	my ($class, @sig) = @_;

	my $method = join "", map "$_\$", @sig;
	my $i = 0;
	my $c = 'a';
	my $meth = join " ", map { $i++ % 2==0? $_: $c++ } @sig;

	local $_ = readfile "barsum/$class/$method.is";

	$lineno = 1;
	$charno = 1;
	@lines = split /\n/;

	# читаем сигнатуру метода
	my $A = qr/[a-z]/i;
	my $WORD = qr/[a-z]\w+/;
	my $S = qr/[ \t]+/;
	$_ = pop @lines;
	/^( &? $A $S )? ( $WORD | ($WORD &? $A $S)+ ) \n/ix or err("Не распознана сигнатура метода $class $meth");

	# распознаём


	# читаем строки метода
	my @ret;
	for(@lines) {
		$lineno++;
		$charno = 1;

		if(//)

		push @ret, exp($_);
	}

	my $ret = join "", map { "\t$_\n" } @ret;
	$ret = "$class\$ $class\$$method() {
$ret
}
";

	writefile ".issa/$bin/$class/$method.c", $ret;

}