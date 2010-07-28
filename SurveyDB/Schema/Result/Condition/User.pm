package SurveyDB::Schema::Result::Condition::User;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('cond_user');
__PACKAGE__->add_columns(qw/topic uid/);
__PACKAGE__->belongs_to('topic' => 'SurveyDB::Schema::Result::Topic');
__PACKAGE__->set_primary_key(qw/topic uid/);

1;
