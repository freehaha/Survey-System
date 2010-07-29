
/*
test code:
    drop database test;
    create database test;
    use test;
*/

/*
    Changes:
        rename table 'option' to 'options' because of sql keyword.
        rename table 'question' to 'questions'
        use 'varchar' instead of 'text'.
*/

create table topic (
	topic integer not null auto_increment primary key,
	creator integer, -- owner
	timelimit integer,
	title varchar(120) NOT NULL,
	description varchar(240), 
	begin_date date,
	close_date date
);

create table questions (
	qid integer not null auto_increment PRIMARY KEY,
	type varchar(15) not null,
	questions varchar(100) not null,
	sn integer not null,
	topic integer not null references topic(topic)
);

create table options (
	oid integer not null auto_increment primary key,
	text varchar(90) not null,
	point integer,
	questions integer not null references questions(qid)
);

-- every choice made will be an answer row
create table answer (
	aid integer not null auto_increment primary key,
	user integer,
	response varchar(64),
	options integer,
	questions integer not null references questions(qid)
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
	chatroom varchar(64),
	primary key (topic, chatroom)
);

create table cond_bot (
	topic integer not null references topic(topic),
	bot varchar(255),
	primary key (topic, bot)
);

create table cond_query (
	topic integer not null references topic(topic),
	query varchar(255),
	primary key (topic, query)
);

create table cond_event (
	topic  integer not null references topic(topic),
	event  varchar(255),
	primary key (topic, event)
);
