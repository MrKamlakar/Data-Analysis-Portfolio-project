Coronavirus disease 2019 (COVID-19) is a contagious disease caused by a virus, the severe acute respiratory syndrome coronavirus 2 
(SARS-CoV-2). The first known case was identified in Wuhan, China, in December 2019.[5] The disease quickly spread worldwide, resulting in 
the COVID-19 pandemic.
The symptoms of COVID‑19 are variable but often include fever,[6] cough, headache,[7] fatigue, breathing difficulties, 
loss of smell, and loss of taste.[8][9][10] Symptoms may begin one to fourteen days after exposure to the virus. At least a third of 
people who are infected do not develop noticeable symptoms.[11] Of those who develop symptoms noticeable enough to be classified as patients, 
most (81%) develop mild to moderate symptoms (up to mild pneumonia), while 14% develop severe symptoms (dyspnea, hypoxia, or more than 50% lung involvement
on imaging), and 5% develop critical symptoms (respiratory failure, shock, or multiorgan dysfunction).[12] Older people are at a higher risk of 
developing severe symptoms. Some people continue to experience a range of effects (long COVID) for months after recovery, and damage to 
organs has been observed.[13] Multi-year studies are underway to further investigate the long-term effects of the diseas.

In this project I am exploring the covid-19 data


------Here we will use two tables CovidDeaths and CovidVaccination------

---Explore the data
select * from Sqlproject.dbo.CovidDeaths order by 3,4;

select * from Sqlproject.dbo.CovidVaccinations

select location,date,total_cases,new_cases,total_deaths,population 
from Sqlproject.dbo.CovidDeaths order by 1,2

------Total cases vs total deaths------
select location,date,total_cases,total_deaths from Sqlproject.dbo.CovidDeaths
order by 1,2

------Probability of deaths if infected in India------

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as prob_death 
from Sqlproject.dbo.CovidDeaths where location ='india' order by 1,2

------Total_cases vs Total_deaths------
select location,date,total_cases,total_deaths from Sqlproject.dbo.CovidDeaths
order by 1,2


------Total cases vs Polulation------
------Percentage of population infected------
select location,date,total_cases,population,(total_cases/population)*100 as percent_pop_infected  
from Sqlproject.dbo.CovidDeaths ---where location like 'states' 
order by 1,2

------Highest infected countries as compared to population-----
select location,population,max(total_cases) as Highest_infection,
max(total_cases/population)*100 as percencentage_infect
from Sqlproject.dbo.CovidDeaths group by location,population 
order by percencentage_infect desc


------continent with highet deaths per population------
select continent,max(cast(total_deaths as int)) as total_deaths_count from 
Sqlproject.dbo.CovidDeaths where continent 
is not null group
by continent order by total_deaths_count desc

------countries with highet deaths per population------
select location,max(cast(total_deaths as int)) as total_deaths_count 
from Sqlproject.dbo.CovidDeaths where continent 
is null group
by location,population order by total_deaths_count desc

select count(location) from Sqlproject.dbo.CovidDeaths where continent 
is null and location = 'europe'

------globally(Total Across the world)------

select date,sum(new_cases),sum(cast(new_deaths as int)),
sum(cast(new_deaths as int))/sum(cast(new_cases as int))*100
as death_percentage
from Sqlproject.dbo.CovidDeaths where continent is not null group by date
order by 1,2

select sum(new_cases),sum(cast(new_deaths as int)),sum(cast(new_deaths as int))/sum(new_cases)*100
as death_percentage
from Sqlproject.dbo.CovidDeaths where continent is not null ---group by date
order by 1,2

--------Joinning the tables------

select * from Sqlproject.dbo.CovidDeaths death
join 
Sqlproject.dbo.CovidVaccinations vaccination on death.location=vaccination.location and 
death.date=vaccination.date


------Total population vs total Vaccination------
select death.continent,death.location,death.date,vaccination.new_vaccinations,
sum(cast(vaccination.new_vaccinations as int)) over (partition by death.location order by death.date) as
vacation_upto_date,
population 
from Sqlproject.dbo.CovidDeaths death 
inner join 
Sqlproject.dbo.CovidVaccinations vaccination 
on death.location=vaccination.location and 
death.date=vaccination.date where  death.continent
is not null  order by 2,3

------Cte(Common Table expression)------

with popvsvacci (continent,location,date,population,new_vaccinations,vacation_upto_date) 
as
(
select death.continent,death.location,death.date,population ,vaccination.new_vaccinations,
sum(cast(vaccination.new_vaccinations as int )) over (partition by death.location order by death.date) as
vacation_upto_date

from Sqlproject.dbo.CovidDeaths death 
join 
Sqlproject.dbo.CovidVaccinations vaccination 
on death.location=vaccination.location and 
death.date=vaccination.date where  death.continent is not null
)
select *, (vacation_upto_date/population) as percent_vacc_upto_date from popvsvacci

--------Temp table------
drop table percentage_population_vaccinated
create table percentage_population_vaccinated( 
continent varchar(270),location varchar(270), date datetime,population numeric,new_vaccinations numeric,
vacation_upto_date numeric)

insert into percentage_population_vaccinated
select death.continent,death.location,death.date,population ,vaccination.new_vaccinations,
sum(cast(vaccination.new_vaccinations as int )) over (partition by death.location order by death.date) as
vacation_upto_date
from Sqlproject.dbo.CovidDeaths death 
join 
Sqlproject.dbo.CovidVaccinations vaccination 
on death.location=vaccination.location and 
death.date=vaccination.date where  death.continent is not null
select *, (vacation_upto_date/population) as percent_vacc_upto_date from percentage_population_vaccinated
