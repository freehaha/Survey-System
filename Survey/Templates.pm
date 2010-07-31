package Survey::Templates;

use utf8;
use Template::Declare::Tags;
use base 'Template::Declare';
use strict;
use warnings;

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
		attr {
			onsubmit => 'return add_form(this);',
		};
		div {
			span { '標題:' };
			input { attr{ id=>'title', name => 'title',  type=>'text' } };
		};
		div {
			span {'敘述:' };
			input { attr{ id=>'desc', name => 'description',  type=>'text' } };
		};
		div {
			span {'開始日期:'};
			show('date_selector', 'begin_date');
		};
		div {
			span {'結束日期:'};
			show('date_selector', 'close_date');
		};
		div {
			span {'作答時間:'};
			select {
				attr { name => 'tl_min' };
				option { $_ } for (0..60);
			};
			span { '分' };
			select {
				attr { name => 'tl_sec' };
				option { $_ } for (0..60);
			};
			span { '秒' };
		};
		show('question_editor');
		show('condition_editor');
		div {
	 		attr { id => 'formBtns' };
			input { attr{ id=> 'btnSubmit', value=>'新增問卷', type=>'submit' } };
			input { attr{ value=>'重新來過', type=>'reset' } };
		}
	}
	show('veil');
};

private template edit_form => sub {
	my $self = shift;
	my $topic = shift || die 'no topic specified';
	my $already_answered = $topic->finished->count;
	form {
		attr {
			id => 'editform',
			onsubmit => 'return add_form(this);',
		};
		div {
			span { '標題:' };
			input {
				attr {
					id=>'title',
					readonly => 'readonly',
					name => 'title',
					type=> 'text',
					value=> $topic->title
				}
			};
		};
		div {
			span {'敘述:' };
			input { attr{ id=>'desc', name => 'description',  type=>'text', value => $topic->description } };
		};
		div {
			span {'開始日期:'};
			if($already_answered) {
				use POSIX qw(strftime);
				span { strftime('%F', localtime($topic->get_column('begin_date'))); };
			} else {
				show('date_selector', 'begin_date', $topic->get_column('begin_date'));
			}
		};
		div {
			span {'結束日期:'};
			show('date_selector', 'close_date', $topic->get_column('close_date'));
		};
		div {
			my $tl = $topic->timelimit || 0;
			span {'作答時間:'};
			select {
				attr { id => 'tl_min', name => 'tl_min', class => 'timeselect' };
				option { attr { value => int($tl / 60) }; int($tl / 60); };
				option { attr { value => $_ }; $_ } for (0..60);
			};
			span { '分' };
			select {
				attr { id => 'tl_sec', name => 'tl_sec', class => 'timeselect' };
				option { attr { value => $tl % 60 }; $tl % 60; };
				option { attr { value => $_ }; $_ } for (0..60);
			};
			span { '秒' };
		};
		script {
			outs_raw '
				$("#begin_date").change(function() {
					changeDate($(this));
				});
				$("#close_date").change(function() {
					changeDate($(this));
				});
				$(".timeselect").change(function() {
					changeTime($(this));
				});
			';
		};
		if($already_answered) {
			show('questions_container', $topic->questions);
		} else {
			show('question_editor', $topic->questions);
		}
		show('condition_editor', $topic);
		div {
			input {
				attr {
					id => 'btnDelete',
					type => 'button',
					value => '刪除問卷',
				}
			}
			script {
				outs_raw '
				$("#btnDelete").click(
					function () {
						deleteTopic();
					}
				);';
			};
		}
	}
	show('veil');
};

private template questions_container => sub {
	my $self = shift;
	my $questions = shift;
	div {
		attr { id => 'qbox' };
		outs '題目:';
		while(my $question = $questions->next) {
			show('question', $question);
		}
	}
};

private template question => sub {
	my $self = shift;
	my $question = shift;
	div {
		attr { class => 'qbox' };
		show('qtype', $question);
		span { $question->questions };
	};
};

my %qtype_lookup = (
	'custom-choice' => '選擇題(自訂)',
	'likert-choice' => '選擇題',
	'open-question' => '自由回答',
);
private template qtype => sub {
	my $self = shift;
	my $question = shift;
	my $qtype = $question->type;
	div{
		attr { class => 'qtype' };
		span {
			$qtype_lookup{$qtype};
		}
	};
};

private template veil => sub {
	div{
		attr { id => 'veil' };
		div {
			attr { id => 'veilbg', class => 'veil' };
		};
		div {
			attr { id => 'veilimg' };
			img { attr { src => '/static/image/ajax-loader.gif' }; };
		}
	}
};

template date_selector => sub {
	my $self = shift;
	my $id = shift || die 'no id supplied for date_selector';
	my $default = shift;
	use POSIX qw(strftime);
	if($default) {
		$default = strftime '%F', localtime($default);
	}

	input {
		attr {
			id => $id, name => $id, type => 'text',
			value => $default
		}
	}
	script { attr { type => 'text/javascript' }
		outs_raw '$("#'.$id.'").datepicker(
		{ dateFormat: \'yy-mm-dd\' });';
	}
};

template question_editor => sub {
	use JSON;
	my $json = JSON->new->utf8(0);
	my $self = shift;
	my $questions = shift;
	div {
		attr { id => 'div_qedit' };
		div {
			attr { id => 'qbox' };
			if($questions) {
				use DBIx::Class::ResultClass::HashRefInflator;
				$questions = $questions->search_rs({}, { order_by => {-asc => 'sn'}, prefetch => 'options' });
				$questions->result_class('DBIx::Class::ResultClass::HashRefInflator');
				script {
					outs_raw 'add_question_set('
					.$json->encode([$questions->all])
					.');';
				}
			}
		};
		input { attr { id => 'btnNewQuestion', type => 'button', value => '新增問題' } };
		if($questions) {
			input { attr { id => 'btnSaveQuestion', type => 'button', value => '儲存變更' } };
			script {
				outs_raw '
				$("#btnSaveQuestion").click(
					function() {
						saveQuestions();
					}
				);'
			}
		}
		script {
			outs_raw '
			var count = 0;
			$("#btnNewQuestion").click(
				function() {
					count++;
					add_question(count);
				}
			);'
		}
	}
};

template condition_editor => sub {
	my $self = shift;
	my $topic = shift;
	div {
		attr { id => 'div_condedit' };
		div {
			attr { id => 'cond_box', class => 'cond_box' };
			if($topic) {
				show('conditions', $topic);
			}
		};
		input { attr { id => 'btnNewCondition', type => 'button', value => '新增條件' } };
		span { '(以逗號區隔)' };
		script {
			outs_raw '
			var c_count = 0;
			$("#btnNewCondition").click(
				function() {
					c_count++;
					add_condition(c_count);
				}
			);'
		};
	}
};

private template custom_options => sub {
	input {
		attr {
			class => 'btn_add',
			type => 'button',
			value => '新增選項',
		};
	};
	input {
		attr {
			class => 'btn_rm',
			type => 'button',
			value => '減少選項',
		};
	};
	div {
		attr { class => 'option_box' };
		div {
			attr { class => 'option' };
			select {
				attr { name => 'pt' };
				foreach my $pt (1..20) {
					option {
						attr { value => $pt };
						$pt;
					}
				}
			};
			input {
				attr { class => 'option', name => 'option' };
			};
		};
	};
};
private template likert_options => sub {
	span { '選項數目: ' };
	select {
		attr { name => 'lkt' };
		foreach my $i (2..9) {
			option {
				attr { value => $i };
				$i;
			};
		}
	};
};

my %cond_types = (
	user => ['uid', '使用者'],
	group => ['gid', '群組'],
	event => ['event', '事件'],
	query => ['query', '字串'],
	bot => ['bot', '機器人'],
	chatroom => ['chatroom', '聊天室'],
);
private template conditions => sub {
	my $self = shift;
	my $topic = shift;
	span { '施測對象:' };
	foreach (keys %cond_types) {
		my $conditions = $topic->search_related_rs('cond_'.$_);
		my @conds  = ();
		while(my $condition = $conditions->next) {
			push @conds, $condition->get_column($cond_types{$_}->[0]);
		}
		#TODO: we probably will like to convert uid or gid into names
		show('condition', $_, @conds) if @conds;
	}
};

template condition => sub {
	my $self = shift;
	my $cond_type = shift;
	my @conds = @_;
	div {
		attr { ctype => $cond_type, id => 'cbox', class => 'condition' };
		div {
			attr { class => 'ctype'};
			span { $cond_types{$cond_type}->[1] };
		};
		input {
			attr {
				name => 'cond',
				type => 'text',
				origin => join(',', @conds),
				value => join(',', @conds),
			};
		};
		div {
			attr { class => 'close' };
			"X";
		}
		input {
			attr {
				class => 'btnSubmitChange',
				type => 'button',
				value => '確認變更',
			};
		};
	}
	script {
		outs_raw '
		$(".close:last").click(
			function () {
				removeCondition($(this).parent());
			}
		);
		$(".btnSubmitChange:last").click(
			function () {
				changeCondition($(this).parent());
			}
		);'
	};
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

private template import_css => sub {
	my $self = shift;
	my $css = shift || return;
	link {
		attr {
			rel => 'stylesheet',
			type => 'text/css',
			href => $css,
		}
	}
};

template add => sub {
	my $self = shift;

	html {
		head {
			title { '新增問卷' };
			meta  {
				attr { content => "text/html; charset=utf-8" }
				attr { 'http-equiv' => "content-type" }
			}
			link {
				attr {
					type => "text/css",
					href => "/static/css/ui-lightness/jquery-ui-1.8.2.custom.css",
					rel => "stylesheet"
				}
			};
			show('import_css', '/static/css/form.css');
			show('include_script', '/static/js/jquery-1.4.2.min.js');
			show('include_script', '/static/js/jquery-ui-1.8.2.custom.min.js');
			show('include_script', '/static/js/surveyui.js');
		}
		body {
			show('add_form');
		};
	}
};

template edit => sub {
	my $self = shift;
	my $topic = shift || die 'no topic';
	html {
		head {
			title { '編輯問卷' };
			meta  {
				attr { content => "text/html; charset=utf-8" }
				attr { 'http-equiv' => "content-type" }
			}
			link {
				attr {
					type => "text/css",
					href => "/static/css/ui-lightness/jquery-ui-1.8.2.custom.css",
					rel => "stylesheet"
				}
			};
			show('import_css', '/static/css/form.css');
			show('include_script', '/static/js/jquery-1.4.2.min.js');
			show('include_script', '/static/js/jquery-ui-1.8.2.custom.min.js');
			show('include_script', '/static/js/surveyui.js');
		}
		body {
			show('edit_form', $topic);
		};
	}
};
