package Survey::Edit;
use utf8;
use Survey::Templates;
use parent qw(Tatsumaki::Handler);

Template::Declare->init( dispatch_to => ['Survey::Templates'] );

sub get {
	my $self = shift;
	my $query = shift;
	my ($dbuser, $dbpwd) = ('test', '12345');
	my $schema = SurveyDB::Schema->connect(
		'dbi:mysql:dbname=test',
		$dbuser, $dbpwd,
		{ mysql_enable_utf8 => 1}
	);
	my $topic = $schema->resultset('Topic')->search(
		{
			topic => $query,
		}
	)->first;
	if($topic) {
		$self->write(Template::Declare->show('edit', $topic));
	} else {
		$self->write('問卷不存在');
	}
}

1;

package Survey::EditTopic;
use parent qw/Tatsumaki::Handler/;
use JSON;
use utf8;
use SurveyDB::Schema;
use Survey::Templates;
use Time::Local;
Template::Declare->init( dispatch_to => ['Survey::Templates'] );

my ($dbuser, $dbpwd) = ('test', '12345');
my $schema = SurveyDB::Schema->connect(
	'dbi:mysql:dbname=test',
	$dbuser, $dbpwd,
	{ mysql_enable_utf8 => 1}
);
%cmds = (
	'remove_cond' => \&remove_condition,
	'change_cond' => \&change_condition,
	'remove_topic' => \&remove_topic,
	'change_date' => \&change_date,
	'change_timelimit' => \&change_timelimit,
);

sub remove_topic {
	my $self = shift;
	my $topic = shift;
	my $query = shift;
	my $json = JSON->new->utf8(0);

	$topic->delete;
	$self->write($json->encode({'success', 'success'}));
}

sub remove_condition {
	my $self = shift;
	my $topic = shift;
	my $query = shift;
	my $ctype = $query->{target};
	my $json = JSON->new->utf8(0);
	@targets = split /[,\s]/, $query->{values};
	#TODO: will dispatching helps here/
	if($ctype eq 'user') {
		my $uids = $topic->cond_user->search_rs(
			{ uid => {'-in' => \@targets }, }
		);
		$uids->delete;
		if($topic->cond_user->search()->count == 0){
			$topic->cond_user->create(
				{uid => 0}
			);
			$self->write($json->encode({
				insert => Template::Declare->show('condition', $ctype, 0),
				success => 'success'
			}));
			return;
		} else {
			$self->write($json->encode({success => 'success'}));
		}
	} elsif($ctype eq 'group') {
		my $gids = $topic->cond_group->search_rs(
			{ gid => {'-in' => \@targets }, }
		);
		$gids->delete;
		if($topic->cond_group->search()->count == 0){
			$topic->cond_group->create(
				{gid => 0}
			);
			$self->write($json->encode({
				insert => Template::Declare->show('condition', $ctype, 0),
				success => 'success'
			}));
			return;
		} else {
			$self->write($json->encode({success => 'success'}));
		}
	} elsif($ctype eq 'bot') {
		my $bots = $topic->cond_bot->search_rs(
			{ bot => {'-in' => \@targets }, }
		);
		$bots->delete;
		if($topic->cond_bot->search()->count == 0){
			$topic->cond_bot->create(
				{ bot => 'all' }
			);
			$self->write($json->encode({
				insert => Template::Declare->show('condition', $ctype, 'all'),
				success => 'success'
			}));
			return;
		} else {
			$self->write($json->encode({success => 'success'}));
		}
	} elsif($ctype eq 'chatroom') {
		my $cts = $topic->cond_chatroom->search_rs(
			{ chatroom => {'-in' => \@targets }, }
		);
		$cts->delete;
		if($topic->cond_chatroom->search()->count == 0){
			$topic->cond_chatroom->create(
				{ chatroom => 'all' }
			);
			$self->write($json->encode({
				insert => Template::Declare->show('condition', $ctype, 'all'),
				success => 'success'
			}));
			return;
		} else {
			$self->write($json->encode({success => 'success'}));
		}
	} elsif($ctype eq 'event') {
		my $events = $topic->cond_event->search_rs(
			{ event => {'-in' => \@targets }, }
		);
		$events->delete;
		$self->write($json->encode({success => 'success'}));
	} elsif($ctype eq 'query') {
		my $queries = $topic->cond_query->search_rs(
			{ query => {'-in' => \@targets }, }
		);
		$queries->delete;
		$self->write($json->encode({success => 'success'}));
	} else {
		$self->write($json->encode({'error' => 'unknown condition type'}));
	}
}

sub change_condition {
	my $self = shift;
	my $topic = shift;
	my $query = shift;
	my $ctype = $query->{target};
	my $json = JSON->new->utf8(0);
	unless(exists $query->{values}) {
		$self->write($json->encode({
			error => '欄位為空'
		}));
		return;
	}
	@targets = split /[,\s]/, $query->{origin};
	#TODO: will dispatching helps here/
	if($ctype eq 'user') {
		my $uids = $topic->cond_user->search_rs(
			{ uid => {'-in' => \@targets }, }
		);
		$uids->delete;
		my @conds = cond_user(split /[,\s]+/, $query->{values});
		$topic->cond_user->populate(
			$conds[1]
		);
		$self->write($json->encode({
					success => 'success',
					origin => join(',', split(/[,\s]+/, $query->{values}))
				}));
	} elsif($ctype eq 'group') {
		my $gids = $topic->cond_group->search_rs(
			{ gid => {'-in' => \@targets }, }
		);
		$gids->delete;
		my @conds = cond_group(split /[,\s]+/, $query->{values});
		$topic->cond_group->populate(
			$conds[1]
		);
		$self->write($json->encode({
					success => 'success',
					origin => join(',', split(/[,\s]+/, $query->{values}))
				}));
	} elsif($ctype eq 'bot') {
		my $bots = $topic->cond_bot->search_rs(
			{ bot => {'-in' => \@targets }, }
		);
		$bots->delete;
		my @conds = cond_bot(split /[,\s]+/, $query->{values});
		$topic->cond_bot->populate(
			$conds[1]
		);
		$self->write($json->encode({
					success => 'success',
					origin => join(',', split(/[,\s]+/, $query->{values}))
				}));
	} elsif($ctype eq 'chatroom') {
		my $chatrooms = $topic->cond_chatroom->search_rs(
			{ chatroom => {'-in' => \@targets }, }
		);
		$chatrooms->delete;
		my @conds = cond_chatroom(split /[,\s]+/, $query->{values});
		$topic->cond_chatroom->populate(
			$conds[1]
		);
		$self->write($json->encode({
					success => 'success',
					origin => join(',', split(/[,\s]+/, $query->{values}))
				}));
	} elsif($ctype eq 'event') {
		my $events = $topic->cond_event->search_rs(
			{ event => {'-in' => \@targets }, }
		);
		$events->delete;
		my @conds = cond_event(split /[,\s]+/, $query->{values});
		$topic->cond_event->populate(
			$conds[1]
		);
		$self->write($json->encode({
					success => 'success',
					origin => join(',', split(/[,\s]+/, $query->{values}))
				}));
	} elsif($ctype eq 'query') {
		my $querys = $topic->cond_query->search_rs(
			{ query => {'-in' => \@targets }, }
		);
		$querys->delete;
		my @conds = cond_query(split /[,\s]+/, $query->{values});
		$topic->cond_query->populate(
			$conds[1]
		);
		$self->write($json->encode({
					success => 'success',
					origin => join(',', split(/[,\s]+/, $query->{values}))
				}));
	} else {
		$self->write($json->encode({'error' => 'unknown condition type'}));
	}
}

sub change_date {
	my $self = shift;
	my $topic = shift;
	my $query = shift;
	my $json = JSON->new->utf8(0);

	unless($query->{target} eq 'begin_date'
		|| $query->{target} eq 'close_date') {
		$self->write($json->encode({error => '日期格式錯誤'}));
		return;
	}
	my @date = split '-', $query->{value}; #yy-mm-dd
	if(scalar(@date) < 3) {
		$self->write($json->encode({error => '日期格式錯誤'}));
		return;
	}
	$topic->update(
		{ $query->{target} => timelocal(0, 0, 0, $date[2], $date[1]-1, $date[0]) }
	);
	$self->write($json->encode({ success => 'success' }));
}

sub change_timelimit {
	my $self = shift;
	my $topic = shift;
	my $query = shift;
	my $json = JSON->new->utf8(0);

	if($topic->update(
			{
				timelimit => $query->{value}
			}
		)){
		$self->write($json->encode({ success => 'success' }));
	} else {
		$self->write($json->encode({error => '系統發生問題'}));
	}
}

sub get {
	my $self = shift;
	my $topic = shift;
	my $query = shift;

	my ($dbuser, $dbpwd) = ('test', '12345');
	my $schema = SurveyDB::Schema->connect(
		'dbi:mysql:dbname=test',
		$dbuser, $dbpwd,
		{ mysql_enable_utf8 => 1}
	);

	my $json = JSON->new->utf8(0);
	#FIXME: get current user id and check permission here
	my $query = $json->decode($query);
	if(my $proc =  $cmds{$query->{cmd}}) {
		$topic = $schema->resultset('Topic')->find(
			{ topic => $topic },
		);
		$schema->txn_begin;
		my $ret = $proc->($self, $topic, $query);
		$schema->txn_commit;
		return $ret;
	} else {
		$self->write($json->encode({'error' => 'undefined command'}));
		return;
	}
}

1;
