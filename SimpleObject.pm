package XML::SimpleObject;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require AutoLoader;

@ISA = qw(Exporter AutoLoader);
@EXPORT = qw(
	
);
$VERSION = '0.1';

sub attributes {
    my $self = shift;
    my $name = shift;
    if ($self->{ATTRS}) {
        return (%{$self->{ATTRS}});
    }
}

sub attribute {
    my $self = shift;
    my $name = shift;
    if ($self->{ATTRS}) {
        return ${$self->{ATTRS}}{$name};
    }
}

sub value {
    $_[0]->{VALUE};
}

sub name {
    $_[0]->{NAME};
}

sub child {
    my $self = shift;
    my $tag  = shift;
    if (ref($self->{$tag}) eq "ARRAY")
    {
        if (wantarray)
        {
            return (@{$self->{$tag}});
        }
        else
        {
            return (${$self->{$tag}}[0]);
        }
    }
}

sub children {
    my $self = shift;
    my $tag  = shift;
    if (ref($self->{$tag}) eq "ARRAY")
    {
        return (@{$self->{$tag}});
    }
}

sub convert {
    my $self = shift;
    my $array = shift;
    unless (ref($array) eq "ARRAY") { die "not an array: $array\n" }
    my $i = 0;
    foreach my $thisdata (@{$array}) {
        if (ref($thisdata) eq "HASH")
        {
            $self->{ATTRS} = $thisdata;
        }
        elsif ($thisdata eq "0")
        {
            if (${$array}[$i+1] =~ /\w/)
            {
                $self->{VALUE} .= ${$array}[$i+1];
            }
        }
        elsif (ref(${$array}[$i+1]) eq "ARRAY")
        {
            $self->{NAME} = $thisdata;
            push @{$self->{$thisdata}}, new XML::SimpleObject (
                    ${$array}[$i+1]);
        }
        $i++;
    }
}

sub new {
  my $class = shift;
  my $table = shift;
  my $name  = shift;
  my $self = {};
  bless ($self,$class);
  $self->{NAME} = $name;
  $self->convert($table);
  return $self;
}


1;
__END__

=head1 NAME

XML::SimpleObject - Perl extension allowing a simple object representation of a parsed XML::Parser tree.

=head1 SYNOPSIS

  use XML::SimpleObject;

=head1 DESCRIPTION

This is a short and simple class allowing simple object access to a parsed XML::Parser tree, with methods for fetching children and attributes in as clean a manner as possible.

=head1 USAGE

=item $xmlobj = new XML::SimpleObject($parser->parse($XML))


$parser is an XML::Parser object created with Style "Tree":

    my $parser = new XML::Parser (ErrorContext => 2, Style => "Tree");

After creating $xmlobj, this object can now be used to browse the XML tree with the following methods.

=item $xmlobj->child("NAME")


This will return a new XML::SimpleObject object using the child element NAME.

=item $xmlobj->children("NAME")


This will return an array of XML::SimpleObject objects of element NAME. Thus, if $xmlobj represents the top-level XML element, 'children' will return an array of all elements directly below the top-level that have the element name NAME.

=item $xmlobj->value


If the element represented by $xmlobj contains any CDATA, this method will return that text data.

=item $xmlobj->attribute("NAME")


This returns the text for an attribute NAME of the XML element represented by $xmlobj.

=item $xmlobj->attributes


This returns a hash of key/value pairs for all elements in element $xmlobj.

=head1 EXAMPLES

Given this parsed XML document:

  <files>
    <file type="symlink">
      <name>/etc/dosemu.conf</name>
      <dest>dosemu.conf-drdos703.eval</dest>
    </file>
    <file>
      <name>/etc/passwd</name>
      <bytes>948</bytes>
    </file>
  </files>

You can then interpret the tree as follows:

  my $parser = new XML::Parser (ErrorContext => 2, Style => "Tree");
  my $xmlobj = new XML::SimpleObject ($parser->parse($XML));

  print "Files: \n";
  foreach my $element ($xmlobj->child("files")->children("file"))
  {
    print "  filename: " . $element->child("name")->value . "\n";
    if ($element->attribute("type"))
    {
      print "    type: " . $element->attribute("type") . "\n";
    }
    print "    bytes: " . $element->child("bytes")->value . "\n";
  }  

This will output:

  Files:
    filename: /etc/dosemu.conf
      type: symlink
      bytes: 20
    filename: /etc/passwd
      bytes: 948

=head1 AUTHOR

Dan Brian <dbrian@brians.org>

=head1 SEE ALSO

perl(1), XML::Parser.

=cut
