# Copyright 1996-2003 Jesse R Vincent <jesse@bestpractical.com>

use strict;

package Net::RT;

use vars qw/$VERSION/;
$VERSION = '0.00_02';

use SOAP::Lite;
use Data::Dumper;


=head1 NAME

Net::RT - A simple perl module to talk to an RT SOAP server.

=cut


=head2 new

Takes: paramhash:  server => scalar: server URI, 
                   username => scalar: user name to connect with,
                   password => scalar: username's password 

=cut

sub new {


  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $self  = {};
  bless ($self, $class);

    my %args = ( server => undef,
                 uri => 'NETRT', 
                 username => undef,
                password => undef,
                @_);


    $self->{soap} = SOAP::Lite->proxy($args{'server'})->on_fault(sub{ warn "There was a SOAP fault"; die Dumper shift });
                $self->{'soap'}->uri($args{'uri'}) if $args{'uri'};

    return ($self);
}



sub _validate_soap_response {
    my $self = shift;
    my $res = shift;

    if ( !UNIVERSAL::isa($res => 'SOAP::SOM')) {
         print(STDERR join "\n", "--- METHOD RESULT ---", $res || '', '')
    }

  elsif (defined($res) && $res->fault     ) {
     print(STDERR join "\n", "--- SOAP FAULT ---", $res->faultcode, $res->faultstring, '') 
    }
  elsif (!$self->{'soap'}->transport->is_success) {
         print(STDERR join "\n", "--- TRANSPORT ERROR ---", $self->{'soap'}->transport->status, '') 
    } 
    else {
        return ($res->paramsall);
    }
}

=head2 getTicket

Takes: integer ticket id
Returns: deep hash of an RT ticket

=cut

sub getTicket {
    my $self = shift;
    my $ticket_id = shift;
    
    warn "About to ask to fetch it over the net";
    my $res =    $self->soap->getTicket($ticket_id);
    warn "About to validate the reply";
    return ($self->_validate_soap_response($res));    
}

=head2 getTickets

Takes: string: 'RTQL search specification' 
Returns: deep hash of an RT tickets object

=cut

sub getTickets {
    my $self = shift;
    my $search = shift;
    
    warn "About to ask to fetch it over the net";
    my $res =    $self->soap->getTickets($search);
    warn "About to validate the reply";
    return ($self->_validate_soap_response($res));    
}



=head2 updateTicket

=cut

sub updateTicket {
    my $self = shift;
    my %args = ( 
                 id => undef,
                 status => undef,
                 updateType => undef, 
                 mimeEntity => undef, 
                 timeWorked => undef,
                 @_ );


    my $mimeMessage = 'This is a test message';

    warn "About to ask to fetch it over the net";
    my $res =    $self->soap->updateTicket(id => $args{'id'},
                                           status => $args{'status'},
                                           updateType => $args{'updateType'},
                                           mimeMessage => $mimeMessage,
                                           timeWorked => $args{'TimeWorked'});
    warn "About to validate the reply";

    return ($self->_validate_soap_response($res));    

}


warn "Now connecting to the netrt server";
my $netrt = Net::RT->new(server => 'http://root:password@localhost:9999');


warn "Now testing getTicket";
my $hashref = $netrt->getTicket(1);
print "Ticket 1's subject is ". $hashref->{'Subject'};
print Dumper $hashref;
exit ;
if (0) {
warn "Now testing getTickets('id = 1')";
my $hashref = $netrt->getTickets('id = 1');
warn Dumper $hashref;
}


warn "Now testing basic Ticket updates";
my $hashref = $netrt->updateTicket( id => 1,
                        updateType => 'reply',
                        mimeMessage => 'This is a test',
                        subject => 'This is a subject',
                        status => 'resolved',
                        timeWorked => 20);

warn Dumper $hashref;

sub soap {
    my $self = shift;
    warn "About to hand off the SOAP object";
    return($self->{'soap'});
}
1;

