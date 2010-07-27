package SurveyDB::Schema::Result::Finished;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('question');
__PACKAGE__->add_columns(qw/user topic/);
__PACKAGE__->belongs_to('topic' => 'SurveyDB::Schema::Result::Topic');

1;
