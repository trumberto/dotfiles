#!/usr/bin/perl

# Written by Kyle Wheeler

use Switch;
use HTML::Parser;
use Getopt::Std;

my %options=();
&getopt("o:HhT",\%options);

if (defined $options{h}) {
	print "Usage: tagurl {options} <message\n";
	print "\t-o file\tPrint mutt macros to the specified file\n";
	print "\t-H\tForce the input to be interpreted as HTML\n";
	print "\t-T\tForce the input to be interpreted as plain text\n";
	print "\t-h\tDisplay this usage information.\n";
	exit;
}

sub sanitizeuri {
	my($uri) = @_;
	my %encoding = (
		#"\!" => "%21",
		#"\*" => "%2A",
		"\'" => "%27",
		#"\(" => "%28",
		#"\)" => "%29",
		#"\;" => "%3B",
		#"\:" => "%3A",
		#"\@" => "%40",
		#"\&" => "%26",
		#"\=" => "%3D",
		#"\+" => "%2B",
		"\\\$" => "%24",
		#"\," => "%2C",
		#"\/" => "%2F",
		#"\?" => "%3F",
		#"\%" => "%25",
		#"\#" => "%23",
		#"\[" => "%5B",
		#"\]" => "%5D",
	);
	foreach $dangerchar (keys %encoding) {
		$uri =~ s/$dangerchar/$encoding{$dangerchar}/g;
	}
	return $uri;
}

my $del = $/;
undef $/;
$input = <STDIN>;
$/ = $del;
undef $del;

my $browser = "open";
if (open(PREFFILE,'<',$ENV{'HOME'}."/.tagurl")) {
	while (<PREFFILE>) {
		if (/^COMMAND (.*)/) {
			$browser = $1;
		}
	}
	close PREFFILE;
}

# create a hash of html tag names that may have links
my %link_attr = (
	'a' => {'href'},
);

my $macrofile;
if (defined $options{o}) {
	$macrofile = $options{o};
} else {
	$macrofile = $ENV{'HOME'}."/.tagurl.macro-output";
}
open(MACRO,'>',$macrofile) or die "cannot open $macrofile: $!";

if (defined $options{H} || (!defined $options{T} && $input =~ /<(html|HTML)[^>]*>.*<\/(html|HTML)>/)) {
	my $parser = HTML::Parser->new(api_version=>3);
	my $linkcount = 0;
	my $opena=0;
	$parser->handler(start => sub {
			my($tagname,$pos,$text) = @_;
			my $printtag = 0;
			if (my $link_attr = $link_attr{$tagname}) {
				while (4 <= @$pos) {
					my($k_offset, $k_len, $v_offset, $v_len) = splice(@$pos,-4);
					my $attrname = lc(substr($text, $k_offset, $k_len));
					next unless exists($link_attr->{$attrname});
					next unless $v_offset; # 0 v_offset means no value
					my $v = substr($text, $v_offset, $v_len);
					$v =~ s/^([\'\"])(.*)\1$/$2/;
					$linkcount ++;
					if ($linkcount < 10) {
						print MACRO "macro pager $linkcount '<shell-escape>$browser ".&sanitizeuri($v)."<enter>'\n";
						$printtag=1;
						$opena=1;
					}
				}
			}
			print $text;
			print "[$linkcount]" if ($printtag == 1);
		},
		"tagname, tokenpos, text");
	$parser->handler(end=>sub{
			my($tagname,$text)=@_;
			if ($opena == 1 && $tagname eq "a" && $linkcount < 10) {
				print "[$linkcount]$text";
				$opena = 0;
			} else {
				print $text;
			}
		},"tagname, text");
	$parser->handler(default=>sub{my($t)=@_;print"$t";},"text");
	$parser->parse($input);
} else {
	my $linkcount = 0;
	sub urlfind {
		my($url) = @_;
		$linkcount ++;
		if ($linkcount < 10) {
			print MACRO "macro pager $linkcount '<shell-escape>$browser ".&sanitizeuri($url)."<enter>'\n";
			return "[$linkcount]".$url."[$linkcount]";
		} else {
			return $url;
		}
	}
	$input =~ s{(((mms|ftp|http|https)://|news:)[][A-Za-z0-9_.~!*'();:@&=+$,/?%#-]+[^](,.'">;[:space:]]|(mailto:)?[-a-zA-Z_0-9.+]+@[-a-zA-Z_0-9.]+)}{
		&urlfind($1);
	}eg;
	print "$input";
}
close MACRO;
