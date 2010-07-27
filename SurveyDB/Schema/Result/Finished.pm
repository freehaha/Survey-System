package SurveyDB::Schema::Result::Finished;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('question');
__PACKAGE__->add_columns(qw/fid topic uid/);
__PACKAGE__->belongs_to('topic' => 'SurveyDB::Schema::Result::Topic');
__PACKAGE__->set_primary_key('fid');

1;
