package SurveyDB::Schema::Result::Option;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('option');
__PACKAGE__->add_columns(qw/oid question text/);
__PACKAGE__->set_primary_key('oid');
__PACKAGE__->belongs_to('question' => 'SurveyDB::Schema::Result::Question');
__PACKAGE__->has_many('answer' => 'SurveyDB::Schema::Result::Answer');

1;
