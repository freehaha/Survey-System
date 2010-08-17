package SurveyDB::Schema::Result::Condition::Chatroom;
use base qw/DBIx::Class::Core/;
use strict;
use warnings;

__PACKAGE__->table('cond_chatroom');
__PACKAGE__->add_columns(qw/topic chatroom/);
__PACKAGE__->belongs_to('topic' => 'SurveyDB::Schema::Result::Topic');
__PACKAGE__->set_primary_key(qw/topic chatroom/);

1;
