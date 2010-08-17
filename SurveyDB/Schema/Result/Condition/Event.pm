package SurveyDB::Schema::Result::Condition::Event;
use base qw/DBIx::Class::Core/;
use strict;
use warnings;

__PACKAGE__->table('cond_event');
__PACKAGE__->add_columns(qw/topic event/);
__PACKAGE__->belongs_to('topic' => 'SurveyDB::Schema::Result::Topic');
__PACKAGE__->set_primary_key(qw/topic event/);

1;
