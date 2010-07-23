package SurveyDB::Schema::Result::Answer;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('answer');
__PACKAGE__->add_columns(qw/aid user option/);
__PACKAGE__->set_primary_key('aid');
__PACKAGE__->belongs_to('option' => 'SurveyDB::Schema::Result::Option');

1;
