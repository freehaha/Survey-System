create table topic (
	tid integer primary key,
	user integer, -- creator, owner
	topic text not null,
	description text, 
	begin_date date,
	close_date date
);

create table question (
	qid integer primary key,
	question text not null,
	topic integer not null references topic(tid)
);

create table option (
	oid integer primary key,
	text text not null,
	question integer not null references question(qid)
);

-- every choice made will be an answer row
create table answer (
	aid integer primary key,
	user integer,
	option integer not null references option(oid)
);
