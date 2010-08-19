### app.psgi
use Tatsumaki::Error;
use Tatsumaki::Application;
use Tatsumaki::HTTPClient;
use Tatsumaki::Server;
use strict;
use warnings;

package main;
use Survey::Add;
use Survey::Edit;
use Survey::List;
use Survey::Answer;
use strict;
use warnings;

my $app = Tatsumaki::Application->new([
	'/add/(\S.*)' => 'Survey::AddTopic',
	'/add' => 'Survey::Add',
	'/edit/(\d+)$' => 'Survey::Edit',
	'/edit/(\d+)/(\S.*)$' => 'Survey::EditTopic',
	'/answer/(\d+)$' => 'Survey::Answer',
	'/answer/(\d+)/(\S.*)$' => 'Survey::SubmitAnswer',
	'/list' => 'Survey::List',
	]);

use Plack::Builder;
builder {
	mount "/static" => Plack::App::File->new(root => "./static");
	mount "/" => $app;
}


