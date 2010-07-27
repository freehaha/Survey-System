package SurveyDB::Schema::Result::Condition::Query;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('cond_query');
__PACKAGE__->add_columns(qw/cid topic query/);
__PACKAGE__->belongs_to('topic' => 'SurveyDB::Schema::Result::Topic');
__PACKAGE__->set_primary_key('cid');

1;
