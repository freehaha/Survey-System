package Survey::Add;
use Survey::Templates;
use parent qw(Tatsumaki::Handler);

Template::Declare->init( dispatch_to => ['Survey::Templates'] );

sub get {
	my $self = shift;
	$self->write(Template::Declare->show('add', 'haha'));
}

1;

package Survey::AddTopic;
use parent qw/Tatsumaki::Handler/;
use JSON;
use utf8;
use SurveyDB::Schema;
use Data::Dumper;
use Time::Local;

my $schema = SurveyDB::Schema->connect('dbi:SQLite:survey.db');

sub get {
	my $self = shift;
	my $query = shift;
	my $topic = {
		questions => [],
	};
	$query = decode_json($query);
	my $q_count = 1;
	for(my $i = 0; $i < scalar(@$query); $i++) {
		my $q = $query->[$i];
		my $key = $q->{name};
		if($key eq 'title') {
			$topic->{title} = $q->{value};
		} elsif ($key eq 'description') {
			$topic->{description} = $q->{value};
		} elsif ($key eq 'begin_date' || $key eq 'close_date') {
			my @date = split '-', $q->{value}; #yy-mm-dd
			$topic->{$key} = 
				timelocal(0, 0, 0, $date[2], $date[1]-1, $date[0]);
		} elsif($key eq 'qtype') {
			my $type = $q->{value};
			$i++;
			$q = $query->[$i];
			my $question = $q->{value};
			if($type eq 'likert-choice') {
				my $option_num = 5;
				for($i++; $i < scalar(@$query); $i++) {
					$q = $query->[$i];
					my $key = $q->{name};
					if($key eq 'lkt') {
						$option_num = $q->{value};
					} elsif ($key eq 'qtype') {
						$i--;
						last;
					}
				}
				push(@{$topic->{questions}}, likert_choice($q_count, $question, options $option_num));
				$q_count++;
			} elsif($type eq 'custom-choice') {
			} elsif($type eq 'open-question') {
				for(; $i < scalar(@$query); $i++) {
					$q = $query->[$i];
					my $key = $q->{name};
					if ($key eq 'qtype') {
						$i--;
						last;
					}
				}
				push(@{$topic->{questions}}, open_question($q_count, $question));
				$q_count++;
			}
		} else {
			#$self->write("{'error': 'unknown qtype: $type'}");
			#return;
		}
	}
	$self->write(Dumper($topic));
}

1;
