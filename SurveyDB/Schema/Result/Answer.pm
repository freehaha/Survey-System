package SurveyDB::Schema::Result::Answer;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('answer');
__PACKAGE__->add_columns(qw/question aid user option response/);
__PACKAGE__->set_primary_key('aid');
__PACKAGE__->belongs_to('question' => 'SurveyDB::Schema::Result::Question');

1;
