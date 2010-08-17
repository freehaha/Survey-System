package SurveyDB::Schema::Result::Option;
use base qw/DBIx::Class::Core/;
use strict;
use warnings;

__PACKAGE__->table('options');
__PACKAGE__->add_columns(qw/oid questions point text/);
__PACKAGE__->set_primary_key('oid');
__PACKAGE__->belongs_to('questions' => 'SurveyDB::Schema::Result::Question');

1;
