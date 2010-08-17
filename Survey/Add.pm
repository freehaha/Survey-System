package Survey::Add;
use Survey::Templates;
use parent qw(Tatsumaki::Handler);
use strict;
use warnings;

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
use Time::Local;
use strict;
use warnings;

my $schema = SurveyDB::Schema->connect_surveydb('etc/config.yml');
my %cond_dp = (
	user => \&cond_user,
	group => \&cond_group,
	event => \&cond_event,
	query => \&cond_query,
	bot => \&cond_bot,
	chatroom => \&cond_chatroom,
);
sub get {
	my $self = shift;
	my $query = shift;
	my $json = JSON->new->utf8(0);
	#FIXME: get current user id here
	my $uid = 0;

	my $topic = {
		creator => $uid,
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
			use DateTime::Format::ISO8601;
			my $dt;
			eval {
				my $qhr = $query->[$i+1];
				my $qmin = $query->[$i+2];

				my $str = sprintf "%sT%02d:%02d:00", $q->{value}, $qhr->{value}, $qmin->{value};
				$dt = DateTime::Format::ISO8601->parse_datetime($str);
			};
			if($@) {
				$self->write($json->encode({error => '日期格式錯誤'}));
				return;
			}
			$topic->{$key} = $dt;
			$i += 2;
		} elsif($key eq 'tl_min') {
			my $min = $q->{value};
			$i++;
			$q = $query->[$i];
			my $sec = $q->{value};
			$topic->{timelimit} = $min*60+$sec;
		} elsif($key eq 'qtype') {
			my $type = $q->{value};
			$i++;
			$q = $query->[$i];
			my $question = $q->{value};
			unless($question) {
				$self->write($json->encode({error => '題目空白'}));
				return;
			}
			$i++;
			if($type eq 'likert-choice') {
				my $option_num = 5;
				$q = $query->[$i];
				$option_num = $q->{value};
				push(@{$topic->{questions}}, likert_choice($q_count, $question, options $option_num));
				$q_count++;
			} elsif($type eq 'custom-choice') {
				my $pt;
				my $option;
				my @options = ();
				for(; $i < scalar(@$query); $i++) {
					$q = $query->[$i];
					my $key = $q->{name};
					if($key eq 'pt') {
						$pt = $q->{value};
						$q = $query->[++$i];
						$option = $q->{value};
						push @options, $option, $pt;
					} else {
						$i--;
						last;
					}
				}
				push(@{$topic->{questions}}, custom_choice($q_count, $question, custom_options @options));
				$q_count++;
			} elsif($type eq 'open-question') {
				push(@{$topic->{questions}}, open_question($q_count, $question));
				$q_count++;
			}
		} elsif($key eq 'cond_type') {
			my $type = $q->{value};
			my @cond;
			$q = $query->[++$i];
			if($type =~ /(user|group|bot|chatroom|query|event)/) {
				@cond = $cond_dp{$type}->(split /[,\s]/, $q->{value});
			}
			$topic->{'cond_'.$type} = $cond[1];
		} else {
			#$self->write("{'error': 'unknown qtype: $type'}");
			#return;
		}
	}

	unless($topic->{title}) {
		$self->write($json->encode({error => '沒有標題'}));
		return;
	}
	unless(scalar(@{$topic->{questions}}) > 0) {
		$self->write($json->encode({error => '沒有提供任何題目'}));
		return;
	}
	my $schema = SurveyDB::Schema->connect_surveydb('etc/config.yml');
	$topic = $schema->add_topic($topic);
	$self->write(encode_json({'success' => $topic->topic}));
}

1;
