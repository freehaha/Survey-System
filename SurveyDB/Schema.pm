package SurveyDB::Schema::ResultSet;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

__PACKAGE__->load_components('Helper::ResultSet');

1;


package SurveyDB::Schema;
use base qw/DBIx::Class::Schema/;

__PACKAGE__->load_namespaces(
	default_resultset_class => 'ResultSet',
);

sub add_topic {
	my ($self, $topic) = @_;
	die 'not a hash ref' unless ref($topic) eq 'HASH';

	my $ret = $self->resultset('Topic')->find_or_create({
		begin_date => time(),
		%$topic
	});
	$ret;
}
=begin get_topics
some queries that make sense
1. [uid] in a [chatroom] with a [bot] at a particular [time]
2. [uid] in a [chatroom] says some particular [query] to [bot] or in a [chatroom] at a particular [time]
3. [uid] in a [chatroom] and some [event] happening with some [bot] at some [time]

as a result, uid, chatroom, bot and time are always examed,
if no such conditions exists, assume that all topics qualified.

if query string is supplied, look up in the database with that string.
if there's no result, assume that non of the topics qualified.
same with event.

note that query and event are mutually exclusive.
=cut
sub get_topics {
	my ($self, %cond) = @_;

	my $first = 1;
	my $topics;

	#time filtering
	my $time = time();
	$time = $cond{time} if exists $cond{time};
	$topics = $self->resultset('Topic')->search(
		{
			begin_date => { '<' => $time },
			close_date => { '>' => $time },
		},
		{
			select => ['topic']
		}
	);
	return [] if $topics->count == 0;
	$topics->result_class('DBIx::Class::ResultClass::HashRefInflator');

	if(exists $cond{uid}) {
		my $cond = $self->resultset('Condition::User');
		my $uid = $cond{uid};
		#my @gid = get_gid($uid);
		my $gid = [1,2,3,0];
		my $rs_g = $self->resultset('Condition::Group')->search(
			{gid => [-in => $gid]}, {select => ['topic']}
		);
		my $rs_u = $cond->search({uid => [$uid, 0]}, { select => ['topic']});
		$_->result_class('DBIx::Class::ResultClass::HashRefInflator')
			for ($rs_g, $rs_u);

		$topics = $topics->intersect($rs_u->union($rs_g));
	} else {
		return [];
	}

	my $rs_chatroom;
	if(exists $cond{chatroom}) {
		$rs_chatroom = $self->resultset('Condition::Chatroom')->search(
			{chatroom => [$cond{chatroom}, 'all']}, {select => ['topic']}
		);
	} else {
		$rs_chatroom = $self->resultset('Condition::Chatroom')->search(
			{chatroom => ['all']}, {select => ['topic']}
		);
	}
	return [] if $rs_chatroom->count == 0;
	$rs_chatroom->result_class('DBIx::Class::ResultClass::HashRefInflator');
	$topics = $topics->intersect($rs_chatroom);
	undef $rs_chatroom;
	my $rs_bot;
	if(exists $cond{bot}) {
		$rs_bot = $self->resultset('Condition::Bot')->search(
			{bot => [$cond{bot}, 'all']}, {select => ['topic']}
		);
	} else {
		$rs_bot = $self->resultset('Condition::Bot')->search(
			{bot => ['all']}, {select => ['topic']}
		);
	}
	return [] if $rs_bot->count == 0;
	$rs_bot->result_class('DBIx::Class::ResultClass::HashRefInflator');
	$topics = $topics->intersect($rs_bot);
	undef $rs_bot;


	if(exists $cond{event}) {
		my $rs_event = $self->resultset('Condition::Event')->search(
			{event => [$cond{event}, 'all']}, {select => ['topic']}
		);
		return [] if $rs_event->count == 0;
		$rs_event->result_class('DBIx::Class::ResultClass::HashRefInflator');
		$topics = $topics->intersect($rs_event);
	} elsif(exists $cond{query}) {
		my $rs_query = $self->resultset('Condition::Query')->search(
			{query => [$cond{query}, 'all']}, {select => ['topic']}
		);
		return [] if $rs_query->count == 0;
		$rs_query->result_class('DBIx::Class::ResultClass::HashRefInflator');
		$topics = $topics->intersect($rs_query);
	}

	my @tcs = map{$_->{topic}} $topics->all;
	return \@tcs;
}

1;

package main;
sub custom_choice($$%) {
	my ($sn, $question, %options) = @_;
	return {
			sn => $sn,
			question => $question,
			type => 'custom-choice',
			%options
	};
}

sub likert_choice($$%) {
	my ($sn, $question, %options) = @_;
	return {
			sn => $sn,
			question => $question,
			type => 'likert-choice',
			%options
	};
}

sub open_question($$) {
	my ($sn, $question) = @_;
	return {
			sn => $sn,
			question => $question,
			type => 'open-question',
	};
}

sub options {
	#TODO: apply Likert styles
	my $pt = 0;
	return ( options => [
		map{ $pt++; {text =>  $_, point=>$pt} } @_
	]);
}

sub custom_options(%) {
	my %options = @_;
	return ( options => [
		map{ {text =>  $_, point => $options{$_}} } keys %options
	]);
}

sub cond_user(@) {
	return cond_user => [
		map { {uid => $_} } @_
	];
}
sub cond_group(@) {
	return cond_group => [
		map { {gid => $_} } @_
	];
}
sub cond_event(@) {
	return cond_event => [
		map { {event => $_} } @_
	];
}
sub cond_query(@) {
	return cond_query => [
		map { {query => $_} } @_
	];
}
sub cond_bot(@) {
	return cond_bot => [
		map { {bot => $_} } @_
	];
}
sub cond_chatroom(@) {
	return cond_chatroom => [
		map { {chatroom => $_} } @_
	];
}
1;
