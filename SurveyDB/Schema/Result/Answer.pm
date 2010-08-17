package SurveyDB::Schema::Result::Answer;
use base qw/DBIx::Class::Core/;
use strict;
use warnings;

__PACKAGE__->table('answer');
__PACKAGE__->add_columns(qw/questions aid user options response/);
__PACKAGE__->set_primary_key('aid');
__PACKAGE__->belongs_to('questions' => 'SurveyDB::Schema::Result::Question');

1;
