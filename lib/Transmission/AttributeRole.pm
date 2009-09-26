package Transmission::AttributeRole;

=head1 NAME

Transmission::AttributeRole - For Torrent and Client

=head1 DESCRIPTION

This role is used by L<Transmission::Client> and L<Transmission::Torrent>.
It requires the consuming class to provide the method C<read_all()>.

=cut

use Moose::Role;

requires 'read_all';

=head1 ATTRIBUTES

=head2 client

 $obj = $self->client;

Returns a L<Transmission::Client> object.

=cut

has client => (
    is => 'ro',
    isa => 'Object',
);

=head2 lazy_write

 $bool = $self->lazy_write;
 $self->lazy_write($bool);

Will prevent writeable attributes from sending a request to Transmission.
L</write_all()> can then be used to sync data.

=cut

has lazy_write => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

=head2 eager_read

 $bool = $self->eager_read;

Setting this attribute in constructor forces L</read_all()> to be called.
This will again populate all (or most) attributes right after the object is
constructed (if Transmission answers the request).

=cut

has eager_read => (
    is => 'ro',
    isa => 'Bool',
    default => 0,
    trigger => sub { $_[0]->read_all if($_[1]) },
);

sub _translateCamel {
    my $self = shift;
    my $h    = shift;

    for(keys %$h) {
        (my $key = $_) =~ s/([A-Z]+)/{ "_" .lc($1) }/ge;

        if(my $tr = $self->can("_translate_$key")) {
            $h->{$key} = $tr->( delete $h->{$_} );
        }
        else {
            $h->{$key} = delete $h->{$_};
        }

        if(ref $h->{$key} eq 'HASH') {
            $self->_translateCamel($h->{$key});
        }
    }
}

sub _translate_status {
    return 'queued'      if($_[0] == 1);
    return 'checking'    if($_[0] == 2);
    return 'downloading' if($_[0] == 4);
    return 'seeding'     if($_[0] == 8);
    return 'stopped'     if($_[0] == 16);
    return $_[0];
}

sub _translate_keys {
    my $self = shift;
    my %args = @_;

    for my $orig (keys %args) {
        my $new = $orig;
        $new =~ tr/_/-/;
        $args{$new} = delete $args{$orig};
    }

    return %args;
}

=head1 LICENSE

=head1 AUTHOR

See L<Transmission::Client>

=cut

1;
