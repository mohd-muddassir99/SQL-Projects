
DROP TABLE IF EXISTS emp;

CREATE TABLE emp (
  empno decimal(4,0) NOT NULL,
  ename varchar(10) default NULL,
  job varchar(9) default NULL,
  mgr decimal(4,0) default NULL,
  hiredate date default NULL,
  sal decimal(7,2) default NULL,
  comm decimal(7,2) default NULL,
  deptno decimal(2,0) default NULL
);

DROP TABLE IF EXISTS dept;

CREATE TABLE dept (
  deptno decimal(2,0) default NULL,
  dname varchar(14) default NULL,
  loc varchar(13) default NULL
);

INSERT INTO emp VALUES ('7369','SMITH','CLERK','7902','1980-12-17','800.00',NULL,'20');
INSERT INTO emp VALUES ('7499','ALLEN','SALESMAN','7698','1981-02-20','1600.00','300.00','30');
INSERT INTO emp VALUES ('7521','WARD','SALESMAN','7698','1981-02-22','1250.00','500.00','30');
INSERT INTO emp VALUES ('7566','JONES','MANAGER','7839','1981-04-02','2975.00',NULL,'20');
INSERT INTO emp VALUES ('7654','MARTIN','SALESMAN','7698','1981-09-28','1250.00','1400.00','30');
INSERT INTO emp VALUES ('7698','BLAKE','MANAGER','7839','1981-05-01','2850.00',NULL,'30');
INSERT INTO emp VALUES ('7782','CLARK','MANAGER','7839','1981-06-09','2450.00',NULL,'10');
INSERT INTO emp VALUES ('7788','SCOTT','ANALYST','7566','1982-12-09','3000.00',NULL,'20');
INSERT INTO emp VALUES ('7839','KING','PRESIDENT',NULL,'1981-11-17','5000.00',NULL,'10');
INSERT INTO emp VALUES ('7844','TURNER','SALESMAN','7698','1981-09-08','1500.00','0.00','30');
INSERT INTO emp VALUES ('7876','ADAMS','CLERK','7788','1983-01-12','1100.00',NULL,'20');
INSERT INTO emp VALUES ('7900','JAMES','CLERK','7698','1981-12-03','950.00',NULL,'30');
INSERT INTO emp VALUES ('7902','FORD','ANALYST','7566','1981-12-03','3000.00',NULL,'20');
INSERT INTO emp VALUES ('7934','MILLER','CLERK','7782','1982-01-23','1300.00',NULL,'10');

INSERT INTO dept VALUES ('10','ACCOUNTING','NEW YORK');
INSERT INTO dept VALUES ('20','RESEARCH','DALLAS');
INSERT INTO dept VALUES ('30','SALES','CHICAGO');
INSERT INTO dept VALUES ('40','OPERATIONS','BOSTON');

select * from emp;
select * from dept;
UPDATE dept set deptno = 10 where dname = "HR";
UPDATE dept set deptno = 20 where dname = "IT";
UPDATE dept set deptno = 30 where dname = "Marketing";
#QUESTION NO :- 1 List all departmets names along with employee names assign to each departments iclude dept even if they have no emp.
select d.dname, e.ename from dept as d
left join emp as e on e.deptno = d.deptno ;

#QUESTION NO 2 :- show the d.dname and count of emp in every dept
select d.dname, count(e.empno) FROM emp as e 
right join dept as d on e.deptno = d.deptno
group by d.dname;
#QUESTION NO. 03 show d.name and avg salary of emp in each dept
select d.dname, AVG(e.sal) FROM emp as e 
right join dept as d on e.deptno = d.deptno
group by d.dname;

#QUESTION 4 :- show the ename and thier managers , display no managers for emp who doesnt have manager
select e.empno, e.ename, e.mgr, m.empno, COALESCE(m.ename, "No Manager") as Manager_name from emp as e
left join emp as m on e.mgr = m.empno;

#QUESTION NO 5 :- list the e name and job title who work in chicago
select e.ename, e.job, d.loc from emp as e 
left join dept as d on e.deptno = d.deptno
where d.loc = "CHICAGO";

#QUESTION NO 6:- show the ename and job title who earning higher salary than the avg salary of all emp
select e.ename, e.job, e.sal from emp as e 
where e.sal > (select avg(sal) from emp);

#QUESTION NO 7 :-  show the ename , job title with dept name and loc
SELECT e.ename, e.job, d.dname from emp as e 
left join dept as d on e.deptno = d.deptno;

#QUESTION NO 8 :- SHOW THE HIGHEST AND SECOND HIGHEST SALARY
SELECT ename, sal from emp where sal < (select max(sal) from emp) order by sal desc limit 5;

#QUESTION NO 9 :- List the names of emp who manages by research dept managers
SELECT e.empno, e.ename, e.mgr, 
m.empno, m.mgr, m.deptno, 
d.deptno, d.dname
from emp as e 
right join emp as m on e.mgr = m.empno
right join dept as d on m.deptno = d.deptno
where d.dname = 'RESEARCH';

#QUESTION NO 10:- show the dept name with no. of emp in each dept exclude dept with less than3 employees 
select d.dname, count(e.empno) FROM emp as e 
right join dept as d on e.deptno = d.deptno
group by d.dname
having count(e.empno)>= 3

