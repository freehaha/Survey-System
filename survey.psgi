### app.psgi
use Tatsumaki::Error;
use Tatsumaki::Application;
use Tatsumaki::HTTPClient;
use Tatsumaki::Server;

package MainHandler;
use Survey::Templates;
use parent qw(Tatsumaki::Handler);

Template::Declare->init( dispatch_to => ['Survey::Templates'] );

sub get {
	my $self = shift;
	$self->write(Template::Declare->show('add'));
}

package FeedHandler;
use parent qw(Tatsumaki::Handler);
__PACKAGE__->asynchronous(1);

use JSON;

sub get {
	my($self, $query) = @_;
	my $client = Tatsumaki::HTTPClient->new;
	$client->get("http://friendfeed-api.com/v2/feed/$query", $self->async_cb(sub { $self->on_response(@_) }));
}

sub on_response {
	my($self, $res) = @_;
	if ($res->is_error) {
		Tatsumaki::Error::HTTP->throw(500);
	}
	my $json = JSON::decode_json($res->content);
	$self->write("Fetched " . scalar(@{$json->{entries}}) . " entries from API");
	$self->finish;
}

package StreamWriter;
use parent qw(Tatsumaki::Handler);
__PACKAGE__->asynchronous(1);

use AnyEvent;

sub get {
	my $self = shift;
	$self->response->content_type('text/plain');

	my $try = 0;
	my $t; $t = AE::timer 0, 0.1, sub {
		$self->stream_write("Current UNIX time is " . time . "\n");
		if ($try++ >= 100) {
			undef $t;
			$self->finish;
		}
	};
}

package main;
use Survey::Add;
use Survey::Edit;

my $app = Tatsumaki::Application->new([
	'/stream' => 'StreamWriter',
	'/feed/(\w+)' => 'FeedHandler',
	'/' => 'MainHandler',
	'/add/(\S.*)' => 'Survey::AddTopic',
	'/add' => 'Survey::Add',
	'/edit/(\d+)$' => 'Survey::Edit',
	'/edit/(\d+)/(\S.*)$' => 'Survey::EditTopic',
	]);

use Plack::Builder;
builder {
	mount "/static" => Plack::App::File->new(root => "./static");
	mount "/" => $app;
}


