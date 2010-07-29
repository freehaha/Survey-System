

-- drop database test;
create database test;
use test;

create table topic (
	topic INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	creator INT, -- owner
	timelimit INT,
	title varchar(120) NOT NULL,
	description varchar(240), 
	begin_date date,
	close_date date
);

/*
create table question (
	qid integer primary key,
	type text not null,
	question text not null,
	sn integer not null,
	topic integer not null references topic(topic)
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

create table finished (
	topic integer not null references topic(topic),
	uid integer,
	primary key (topic, uid)
);

create table cond_user (
	topic integer not null references topic(topic),
	uid integer,
	primary key (topic, uid)
);

create table cond_group (
	topic integer not null references topic(topic),
	gid integer,
	primary key (topic, gid)
);

create table cond_chatroom (
	topic integer not null references topic(topic),
	chatroom text,
	primary key (topic, chatroom)
);

create table cond_bot (
	topic integer not null references topic(topic),
	bot text,
	primary key (topic, bot)
);

create table cond_query (
	topic integer not null references topic(topic),
	query text,
	primary key (topic, query)
);

create table cond_event (
	topic integer not null references topic(topic),
	event text,
	primary key (topic, event)
);
*/
