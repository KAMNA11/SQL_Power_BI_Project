select * from hr;
#DATA_CLEANING
alter table hr rename column ï»¿id to employee_id;
select * from hr;
describe hr;
alter table hr modify column birthdate text;
describe hr;
set sql_safe_updates=0;

update hr
set birthdate= case
when birthdate like '%/%' then date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
when birthdate like '%-%' then date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
else Null
end;

alter table hr modify column birthdate Date;

update hr
set hire_date= case
when hire_date like '%/%' then date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
when hire_date like '%-%' then date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
else Null
end;

alter table hr modify column hire_date Date;

update hr
set termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate!=' ';
select termdate from hr;
alter table hr modify column termdate date;
describe hr;

alter table hr add column age int;
select * from hr;
update hr set age = timestampdiff(Year,birthdate,Curdate());
select age from hr where age<=18;
select age from hr where age<18;

#DATA ANALYSIS
#1 Gender_Breakdown_Count
select gender,count(*) as gender_count from hr where age>=18 and termdate='0000-00-00'
group by gender;

#2 Race/Ethnicity_Breakdown
select race,count(*) as race_count from hr where age>=18 and termdate='0000-00-00'
group by race
order by race_count desc;

#3 Age_Distribution
select min(age) as youngest, max(age) as oldest from hr where age>=18 and termdate='0000-00-00';
select case
when age>=18 and age<=24 then '18-24'
when age>=25 and age<=34 then '25-34'
when age>=35 and age<=44 then '35-44'
when age>=45 and age<=54 then '45-54'
when age>=55 and age<=64 then '55-64'
else '65+'
end as age_group, gender, count(*) as age_distribution
from hr where age>=18 and termdate='0000-00-00'
group by age_group,gender
order by age_group,gender;

#4 Location
select location, count(*) as employee_count from hr where age>=18 and termdate='0000-00-00' group by location;

#5 Avg_Employement_Length
select round(avg(datediff(termdate,hire_date))/365,0) as avg_employment_length from hr 
where termdate<=curdate() and termdate!= '0000-00-00' and age>=18;

#6 Gender_Distribution_across_Department 
select department,gender, count(*) as gender_count from hr where age>=18 and termdate='0000-00-00' group by gender,department
order by department;

#7 Gender_Distribution_across_Job Title
select jobtitle,gender, count(*) as gender_count from hr where age>=18 and termdate='0000-00-00' group by gender,jobtitle
order by jobtitle;

#8 Distribution across job title
select jobtitle, count(*) as job_count  from hr where age>=18 and termdate='0000-00-00' group by jobtitle
order by jobtitle;

#9 Highest Department Tunover
select department, total_count, terminated_count, terminated_count/total_count as termination_rate
from ( select department, count(*) as total_count ,
sum(case when termdate!='0000-00-00' and termdate<=curdate()then 1 else 0 end) as terminated_count
from hr
where age>=18 
group by department) as subquery
order by termination_rate desc; 

#10 Location_state count
select location_state,count(*) as count from hr where age>=18 and termdate='0000-00-00'
group by location_state
order by count desc;

#11 Employeecount change over time by hire & term dates
select year, hires, terminations, hires-terminations as net_change, round((hires-terminations)/hires*100,2) as net_change_percent
from( select year(hire_date) as year, count(*) as hires ,
sum(case when termdate!='0000-00-00' and termdate<=curdate()then 1 else 0 end) as terminations
from hr 
where age>=18
group by year(hire_date)
) as subquery 
order by year ;

#12 Tenure Distribution by dept
select department, round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure
from hr 
where termdate!='0000-00-00' and termdate<=curdate() and age>=18
group by department;

