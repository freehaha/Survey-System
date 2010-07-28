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

function change_type(count)
{
	var v = parseInt($("#s_"+count).val());
	$("#qb_"+count+"_inner").empty();
	switch(v) {
		case 1: /* likert-style options */
			$('#qb_'+count+'_inner').append(likert_options());
			$('#s_lkt_'+count).change(
				function() {
				}
			);
			break;
		case 2: /* custom options */
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
		case 3:
			break;
	}
}
function new_option(count) {
	var text = '<div class="option"><select name="pt">';
	for(var i=1;i<=20;i++) {
		text += '<option value='+i+'>'+i+'</option>';
	}
	text += '</select>';
	text += '<input class="option" name="option" /></div>';
	$("#options_"+count).append(text);
}
function rm_option(count) {
	$("#options_"+count+" div:last-child").animate({
		opacity: 0,
		}, 200, function() {
			$(this).remove();
	});
}

function options(count) {
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

function likert_options(count) {
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
	+ '<option value="1" selected="1">選擇題</option>'
	+ '<option value="2">選擇題(自訂)</option>'
	+ '<option value="3">自由回答</option>'
	+ '</select>'
	+ '<span>題目:</span><input name="question" type="text" />'
	+ '<div class="close" id="dv_close_'+count+'">x</div>'
	+ '<div id="qb_'+count+'_inner">'
	+ likert_options(count)
	+ '</div></div>';

	return text;
};
