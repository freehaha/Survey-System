### app.psgi
use Tatsumaki::Error;
use Tatsumaki::Application;
use Tatsumaki::HTTPClient;
use Tatsumaki::Server;

package main;
use Survey::Add;
use Survey::Edit;

my $app = Tatsumaki::Application->new([
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


