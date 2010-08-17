package SurveyDB::Schema::Result::Condition::Query;
use base qw/DBIx::Class::Core/;
use strict;
use warnings;

__PACKAGE__->table('cond_query');
__PACKAGE__->add_columns(qw/topic query/);
__PACKAGE__->belongs_to('topic' => 'SurveyDB::Schema::Result::Topic');
__PACKAGE__->set_primary_key(qw/topic query/);

1;
