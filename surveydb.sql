create table topic (
	tid integer primary key,
	creator integer, -- owner
	topic text not null,
	description text, 
	begin_date date,
	close_date date
);

create table question (
	qid integer primary key,
	type text not null,
	question text not null,
	sn integer not null,
	topic integer not null references topic(tid)
);

create table option (
	oid integer primary key,
	text text not null,
	point integer,
	question integer not null references question(qid)
);

-- every choice made will be an answer row
create table answer (
	aid integer primary key,
	user integer,
	response text,
	option integer,
	question integer not null references question(qid)
);
