--Covid 19 Data Exploration 

--Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

select *
from covid_deaths
where continent is not null
order by 3,4;

select *
from covid_deaths
order by 3,4;

--The data we will be using.

select location,date, total_cases, new_cases,total_deaths, population
from covid_deaths
where continent is not null 
order by 1,2;

--Total cases vs population
--To show the percentage of population that got Covid in Kenya.

select location,date,population, total_cases, (cast(total_cases as float)/population)*100 as percentage_infections
from covid_deaths
where location like 'Kenya'and continent is not null and total_cases is not null
order by 1,2;

--Total cases vs total deaths.
--To show the likelyhood of dying if you contracted covid in Kenya.

select location,date, total_cases,total_deaths,(cast(total_deaths as float)/total_cases)*100 as percentage_deaths
from covid_deaths
where location like 'Kenya'and continent is not null and total_cases is not null
order by 1,2;

--Countries infection rate compared to population
--To show the countries that had the highest infection rate of covid.

select location,population, max(total_cases) as highest_infactioncount,max((cast(total_cases as float)/population)*100)  as highestpercentage_infections
from covid_deaths
where total_cases is not null and continent is not null
group by location, population
order by highestpercentage_infections desc;

--Countries deaths count compared to population
--To show the country who had the highest deathcount per population.

select location,max(cast(total_deaths as float)) as total_deaths_count
from covid_deaths 
where total_deaths is not null and continent is not null
group by location
order by total_deaths_count desc;


--To show continent deaths count compared to population

select location,max(cast(total_deaths as int)) as total_deaths_count_per_continent
from covid_deaths 
where total_deaths is not null and continent is null  
group by location
order by total_deaths_count_per_continent desc


--To show continent covid cases count compared to population.

select continent,max(cast(total_cases as int)) as total_cases_count_per_continent
from covid_deaths 
where continent is not null  
group by continent
order by total_cases_count_per_continent desc


--GLOBAL NUMBERS

--Total covid cases,deaths and percentage deaths across the world

select SUM(new_cases) as total_cases,sum(cast(new_deaths as float)) as total_deaths,sum(cast(new_deaths as float))/SUM(new_cases)*100 as deaths_percentage
from covid_deaths
where continent is not null and new_cases is not null 
order by 1,2;

--Total covid cases,deaths and percentage deaths across the world per day from the first covid case.
select date,SUM(new_cases) as total_cases,sum(cast(new_deaths as float)) as total_deaths,sum(cast(new_deaths as float))/SUM(new_cases)*100 as deaths_percentage
from covid_deaths
where continent is not null and new_cases is not null 
group by date
order by 1,2;

--Looking at total population versus vaccination.
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
Sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as rolling_vaccincount
from covid_deaths dea join covid_vaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and new_cases is not null
order by 2,3;

--USE CTE

With Popvsvac (continent,location,date,population,new_vaccinations,Rolling_vaccincount)
as
(select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
Sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as Rolling_vaccincount
from covid_deaths dea join covid_vaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and new_cases is not null
--order by 2,3
 )
 select *,(Rolling_vaccincount/cast(population as float))*100 as Percent_populationveccinated
 from Popvsvac


--CREATE VIEWS FOR LATER USE.

create view Percent_populationveccinated as
With Popvsvac (continent,location,date,population,new_vaccinations,Rolling_vaccincount)
as
(select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
Sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as Rolling_vaccincount
from covid_deaths dea join covid_vaccinations vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null and new_cases is not null
--order by 2,3
 )
 select *,(Rolling_vaccincount/cast(population as float))*100 as Percent_populationveccinated
 from Popvsvac



















