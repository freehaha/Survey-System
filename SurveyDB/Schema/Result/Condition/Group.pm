package SurveyDB::Schema::Result::Condition::Group;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('cond_group');
__PACKAGE__->add_columns(qw/topic gid/);
__PACKAGE__->belongs_to('topic' => 'SurveyDB::Schema::Result::Topic');
__PACKAGE__->set_primary_key(qw/topic gid/);

1;
