function add_question_set(questions)
{
	$(document).ready(function () {
		for (var i = 0; i < questions.length; ++i) {
			count++;
			add_question(count);
			$('#qb_'+count+' input:first').val(questions[i].questions);
			var index = 0;
			switch(questions[i].type) {
				case 'likert-choice':
					$('#s_'+count)[0].selectedIndex = 0;
					$('#s_'+count).change();
					$('#s_lkt_'+count)[0].selectedIndex = questions[i].options.length-2;
					break;
				case 'custom-choice':
					$('#s_'+count)[0].selectedIndex = 1;
					$('#s_'+count).change();
					$("#options_"+count).empty();
					for(var j = 0; j < questions[i].options.length; ++j) {
						var opt = new_option(count);
						opt.children('select')[0].selectedIndex = questions[i].options[j].point-1;
						opt.children('input').val(questions[i].options[j].text);
					}
					break;
				case 'open-question':
					$('#s_'+count)[0].selectedIndex = 2;
					$('#s_'+count).change();
					break;
			}
		}
	});
}
function add_question(count)
{
	$("#qbox").append(new_question_box(count));
	$("#s_"+count).change(
		function() {
			change_type(count);
		}
	);
	$("#dv_close_"+count).click(
		function() {
			$('#qb_'+count).remove();
		}
	);
}

function add_condition(count)
{
	$("#cond_box").append(new_condition_box(count));
	$('#dv_cclose_'+count).click(
		function () {
			$(this).parent().remove();
		}
	);
}

function new_condition_box(count)
{
	var text = '<div id="cbox_'+count+'">';
	text += '<select name="cond_type"> \
			<option value="user">使用者</option> \
			<option value="group">群組</option> \
			<option value="bot">觸發機器人</option> \
			<option value="chatroom">聊天室</option> \
			<option value="query">查詢條件</option> \
			<option value="event">事件</option> \
			</select>\
			<input name="cond" type="text" /> \
			<div id="dv_cclose_'+count+'" class="close">X</div> \
			</div>';
	return $(text).addClass('condition');
}

function change_type(count)
{
	var v = $("#s_"+count).val();
	$("#qb_"+count+"_inner").empty();
	switch(v) {
		case 'likert-choice': /* likert-style options */
			$('#qb_'+count+'_inner').append(likert_options(count));
			$('#s_lkt_'+count).change(
				function() {
				}
			);
			break;
		case 'custom-choice': /* custom options */
			$('#qb_'+count+'_inner').append(options(count));
			$('#btn_add_'+count).click(
				function() {
					new_option(count);
				}
			);
			$('#btn_rm_'+count).click(
				function() {
					rm_option(count);
				}
			);
			break;
		case 'open-question':
			break;
	}
}
function new_option(count)
{
	var text = '<div class="option"><select name="pt">';
	for(var i=1;i<=20;i++) {
		text += '<option value='+i+'>'+i+'</option>';
	}
	text += '</select>';
	text += '<input class="option" name="option" /></div>';
	return $(text).appendTo('#options_'+count);
}

function rm_option(count)
{
	$("#options_"+count+" div:last-child").animate({
		opacity: 0,
		}, 200, function() {
			$(this).remove();
	});
}

function options(count)
{
	var text = '<input id=btn_add_'+count+' type="button" value="新增選項" />';
	text += '<input id=btn_rm_'+count+' type="button" value="刪除選項" />';
	text += '<div id="options_'+count+'">';
	text += '<div class="option"><select name="pt">';
	for(var i=1;i<=20;i++) {
		text += '<option value='+i+'>'+i+'</option>';
	}
	text += '</select>';
	text += '<input class="option" name="option" /></div></div>';
	return text;
}

function likert_options(count)
{
	var text = '<span>選項數目: </span><select id=s_lkt_'+count+' name="lkt">';
	for(var i=2;i<=9;i++) {
		text += '<option value='+i+'>'+i+'</option>';
	}
	text += '</select>';
	return text;
}

function new_question_box(count) {
	var text = '<div class="qbox" id="qb_'+count+'">'
	+ '<select class="type_sel" name="qtype" id="s_'+count+'">'
	+ '<option value="likert-choice" selected="1">選擇題</option>'
	+ '<option value="custom-choice">選擇題(自訂)</option>'
	+ '<option value="open-question">自由回答</option>'
	+ '</select>'
	+ '<span>題目:</span><input name="question" type="text" />'
	+ '<div class="close" id="dv_close_'+count+'">X</div>'
	+ '<div id="qb_'+count+'_inner">'
	+ likert_options(count)
	+ '</div></div>';

	return text;
};

function add_form(form) {
	$('#btnSubmit').attr('disabled', 'disabled');
	$('#veil').show();
	$.ajax({
		url: '/add/'+window.JSON.stringify($(form).serializeArray()),
		dataType: 'json',
		success: function(data) {
			if (data.error) {
				$('<div>錯誤: ' + data.error + '</div>')
					.addClass('msgbox-alarm')
					.prependTo(document.body)
					.delay(3000)
					.fadeOut(200, function() {
							$(this).remove();
						});

				$('#veil').hide();
				$('#btnSubmit').removeAttr('disabled');
			} else {
				$('<div>成功加入, 將跳轉回新增頁面</div>')
					.addClass('msgbox')
					.prependTo(document.body)
					.delay(3000)
					.fadeOut(200, function() {
							$(this).remove();
							/* FIXME: use relative path ? */
							location = '/add';
						});
				$('#veil').hide();
			}
		},
		error: function() {
			$('<div>執行期發生錯誤, 請聯絡管理員</div>')
				.addClass('msgbox-alarm')
				.prependTo(document.body)
				.delay(3000)
				.fadeOut(200, function() {
						$(this).remove();
					});

			$('#veil').hide();
			$('#btnSubmit').removeAttr('disabled');
		}
	});
	return false;
}

function changeCondition(div)
{
	$('#veil').show();
	var change = {
		'cmd': 'change_cond',
		'target': div.attr('ctype'),
		'origin': div.children('input').attr('origin'),
		'values': div.children('input').val()
	};
	$.ajax({
		/* FIXME: use relative path ? */
		url: location.pathname + '/' + window.JSON.stringify(change),
		dataType: 'json',
		success: function(data) {
			if (data.error) {
				$('<div>錯誤: ' + data.error + '</div>')
					.addClass('msgbox-alarm')
					.prependTo(document.body)
					.delay(3000)
					.fadeOut(200, function() {
							$(this).remove();
						});

				$('#veil').hide();
			} else {
				newdv = $('<div>成功變更</div>')
				newdv
					.addClass('msgbox-inline')
					.appendTo(div)
					.delay(3000)
					.fadeOut(200, function() {
							$(this).remove();
						});

				div.children('input').attr('origin', data.origin);
				$('#veil').hide();
			}
		},
		error: function() {
			$('<div>執行期發生錯誤, 請聯絡管理員</div>')
				.addClass('msgbox-alarm')
				.prependTo(document.body)
				.delay(3000)
				.fadeOut(200, function() {
						$(this).remove();
					});

			$('#veil').hide();
		}
	});
}
function removeCondition(div)
{
	$('#veil').show();
	var remove = {
		'cmd': 'remove_cond',
		'target': div.attr('ctype'),
		'values': div.children('input').val()
	};
	$.ajax({
		/* FIXME: use relative path ? */
		url: location.pathname + '/' + window.JSON.stringify(remove),
		dataType: 'json',
		success: function(data) {
			if (data.error) {
				$('<div>錯誤: ' + data.error + '</div>')
					.addClass('msgbox-alarm')
					.prependTo(document.body)
					.delay(3000)
					.fadeOut(200, function() {
							$(this).remove();
						});

				$('#veil').hide();
			} else {
				var newdv;
				if(data.insert) {
					newdv = $('<div>成功移除篩選條件並補上全域選取條件</div>');
					$(data.insert).appendTo('#cond_box');
				} else {
					newdv = $('<div>成功移除篩選條件</div>')
				}
				newdv
					.addClass('msgbox')
					.prependTo(document.body)
					.delay(3000)
					.fadeOut(200, function() {
							$(this).remove();
						});

				div.remove();
				$('#veil').hide();
			}
		},
		error: function() {
			$('<div>執行期發生錯誤, 請聯絡管理員</div>')
				.addClass('msgbox-alarm')
				.prependTo(document.body)
				.delay(3000)
				.fadeOut(200, function() {
						$(this).remove();
					});

			$('#veil').hide();
		}
	});
}
function deleteTopic()
{
	var del = {
		'cmd': 'remove_topic'
	};
	$('#btnDelete').attr('disabled', 'disabled');
	$.ajax({
		/* FIXME: use relative path ? */
		url: location.pathname + '/' + window.JSON.stringify(del),
		dataType: 'json',
		success: function(data) {
			if (data.error) {
				$('<div>錯誤: ' + data.error + '</div>')
					.addClass('msgbox-alarm')
					.prependTo(document.body)
					.delay(3000)
					.fadeOut(200, function() {
							$(this).remove();
						});

				$('#veil').hide();
				$('#btnDelete').removeAttr('disabled');
			} else {
				var newdv = $('<div>成功移除問卷, 將在三秒後返回選問卷列表</div>')
				newdv
					.addClass('msgbox')
					.prependTo(document.body)
					.delay(3000)
					.fadeOut(200, function() {
							$(this).remove();
							/* FIXME: use relative path ? */
							location = '/list';
						});

				$('#editform').remove();
				$('#veil').hide();
			}
		},
		error: function() {
			$('<div>執行期發生錯誤, 請聯絡管理員</div>')
				.addClass('msgbox-alarm')
				.prependTo(document.body)
				.delay(3000)
				.fadeOut(200, function() {
						$(this).remove();
					});

			$('#veil').hide();
			$('#btnDelete').removeAttr('disabled');
		}
	});
}
function changeDate(input)
{
	var chg = {
		'cmd': 'change_date',
		'target': input.attr('name'),
		'value': input.val()
	};
	$.ajax({
		/* FIXME: use relative path ? */
		url: location.pathname + '/' + window.JSON.stringify(chg),
		dataType: 'json',
		success: function(data) {
			if (data.error) {
				$('<div>錯誤: ' + data.error + '</div>')
					.addClass('msgbox-alarm')
					.prependTo(document.body)
					.delay(3000)
					.fadeOut(200, function() {
							$(this).remove();
						});

				$('#veil').hide();
			} else {
				var newdv = $('<div>變更完成</div>')
				newdv
					.addClass('msgbox-inline')
					.appendTo(input.parent())
					.delay(3000)
					.fadeOut(200, function() {
							$(this).remove();
						});

				$('#veil').hide();
			}
		},
		error: function() {
			$('<div>執行期發生錯誤, 請聯絡管理員</div>')
				.addClass('msgbox-alarm')
				.prependTo(document.body)
				.delay(3000)
				.fadeOut(200, function() {
						$(this).remove();
					});

			$('#veil').hide();
		}
	});
}

function changeTime(input)
{
	var val = parseInt($('#tl_sec').val()) + 60*parseInt($('#tl_min').val());
	var chg = {
		'cmd': 'change_timelimit',
		'value': val
	};
	$.ajax({
		/* FIXME: use relative path ? */
		url: location.pathname + '/' + window.JSON.stringify(chg),
		dataType: 'json',
		success: function(data) {
			if (data.error) {
				$('<div>錯誤: ' + data.error + '</div>')
					.addClass('msgbox-alarm')
					.prependTo(document.body)
					.delay(3000)
					.fadeOut(200, function() {
							$(this).remove();
						});

				$('#veil').hide();
			} else {
				var newdv = $('<div>變更完成</div>')
				newdv
					.addClass('msgbox-inline')
					.appendTo(input.parent())
					.delay(3000)
					.fadeOut(200, function() {
							$(this).remove();
						});

				$('#veil').hide();
			}
		},
		error: function() {
			$('<div>執行期發生錯誤, 請聯絡管理員</div>')
				.addClass('msgbox-alarm')
				.prependTo(document.body)
				.delay(3000)
				.fadeOut(200, function() {
						$(this).remove();
					});

			$('#veil').hide();
		}
	});
}
function saveQuestions() {
	$('#btnSaveQuestion').attr('disabled', 'disabled');
	$('#veil').show();
	var questions = new Array;
	var i = 0;
	$('.qbox').each(function(index, elem) {
		questions[i] = new Object;
		questions[i].type = $(this).children('.type_sel').val();
		switch(questions[i].type) {
		case 'likert-choice':
			questions[i].num = $(this).children('div:last').children('select').val();
			break;
		case 'custom-choice':
			var op_container = $(this).children('div:last').children('div:last');
			var j = 0;
			questions[i].options = new Array();
			op_container.children('div').each(function(index, elem) {
				var option = new Object;
				option.pt = $(this).children('select').val();
				option.text = $(this).children('input').val();
				questions[i].options[j] = option;
				j++;
			});
			break;
		case 'open-question':
			break;
		}
		questions[i].question = $(this).children('input').val();
		i++;
	});
	var save = {
		'cmd': 'save_questions',
		'questions': questions
	};
	$.ajax({
		url: location.pathname + '/' + window.JSON.stringify(save),
		dataType: 'json',
		success: function(data) {
			if (data.error) {
				$('<div>錯誤: ' + data.error + '</div>')
					.addClass('msgbox-alarm')
					.prependTo(document.body)
					.delay(3000)
					.fadeOut(200, function() {
							$(this).remove();
						});

				$('#veil').hide();
				$('#btnSaveQuestion').removeAttr('disabled');
			} else {
				$('<div>儲存成功</div>')
					.addClass('msgbox')
					.prependTo(document.body)
					.delay(3000)
					.fadeOut(200, function() {
							$(this).remove();
						});
				$('#veil').hide();
			}
		},
		error: function() {
			$('<div>執行期發生錯誤, 請聯絡管理員</div>')
				.addClass('msgbox-alarm')
				.prependTo(document.body)
				.delay(3000)
				.fadeOut(200, function() {
						$(this).remove();
					});

			$('#veil').hide();
			$('#btnSaveQuestion').removeAttr('disabled');
		}
	});
	return false;
}
