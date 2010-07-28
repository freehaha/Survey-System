package Survey::Templates;

use Template::Declare::Tags;
use base 'Template::Declare';

private template 'util/header' => sub {
	my $self = shift;
	my $title = shift;
	head {
		title { $title };
		meta  {
			attr { content => "text/html; charset=utf-8" }
			attr { 'http-equiv' => "content-type" }
		}
	}
};

private template 'util/footer' => sub {
	my $self = shift;
	my $time = shift || gmtime;

	div {
		attr { id => "footer"};
		"Page last generated at $time."
	}
};

private template add_form => sub {
	my $self = shift;
	form {
		div {
			span {'Title:' };
			input { attr{ id=>'title', name => 'title',  type=>'text' } };
		};
		div {
			span {'Description:' };
			input { attr{ id=>'desc', name => 'description',  type=>'text' } };
		};
		div {
			span {'Begin Date:'};
			show('date_selector', 'begin_date');
		};
		div {
			span {'Close Date:'};
			show('date_selector', 'close_date');
		};
		show('question_editor');
		input { attr{ value=>'Add', type=>'submit' } };
	}
};

template date_selector => sub {
	my $self = shift;
	my $id = shift || die 'no id supplied for date_selector';
	input { 
		attr {
			id => $id, name => $id, type => 'text'
		}
	}
	script { attr { type => 'text/javascript' }
		outs_raw '$("#'.$id.'").datepicker(
		{ dateFormat: \'yy-mm-dd\' });';
	}
};

template question_editor => sub {
};

private template include_script => sub {
	my $self = shift;
	my $script = shift || return;
	script {
		attr { 
			type => 'text/javascript',
			src => $script,
		}
	}
};

template add => sub {
	my $self = shift;

	html {
		head {
			link {
				attr {
					type => "text/css",
					href => "/static/css/ui-lightness/jquery-ui-1.8.2.custom.css",
					rel => "stylesheet" 
				}
			};
			show('include_script', '/static/js/jquery-1.4.2.min.js');
			show('include_script', '/static/js/jquery-ui-1.8.2.custom.min.js');
		}
		body {
			show('add_form');
		};
	}
};

