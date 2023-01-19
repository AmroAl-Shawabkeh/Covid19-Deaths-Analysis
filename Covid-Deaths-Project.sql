DBCC FREEPROCCACHE --> remove all elements from plan cache for the entire instance. 
DBCC FREEPROCCACHE --> flush the plan cache for the entire instance. 
------------------------------------------------------------------------------
use PortfolioProjects;
---------------------------------------------------------------------------------------

--======================================================using for tableau project======================================================================== 
--global numbers 
Select 
sum(new_cases) as Total_Cases,
sum(cast(new_deaths as int)) as Total_Deaths,
sum(cast(new_deaths as int)) / sum(new_cases) * 100 as Death_Percentage
From CovidDeaths$
where continent is not null
order by 1,2 
	

---------------------------------------------------------------------------------------
--2
--I take these out as they are not inluded in the above queries and want to stay consistant
--European Union is part of Europe
	
select
location, 
sum(cast(new_deaths as int)) as Total_Death_Count
from 
CovidDeaths$
--where location like '%Jordan%'
where continent is null 
and location not in ('World','European Union','International')
Group by location
order by Total_Death_Count desc;
---------------------------------------------------------------------------------------
--3
--looking at countries with highest infection rate compared to population
	
Select 
Location,
population, 
max(total_cases) as Highiest_Infection_Count, 
max((total_cases/population)) * 100 as Percent_Population_Infected
From CovidDeaths$
--where location like 'jordan'
group by location, population
order by Percent_Population_Infected desc ;
---------------------------------------------------------------------------------------
--4
/*
looking at countries with highest infection rate 
compared to population with date
*/

Select 
Location, 
Population,
date, 
MAX(total_cases) as Highest_Infection_Count,  
Max((total_cases / population)) * 100 as Percent_Population_Infected
From CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by Percent_Population_Infected desc
---------------------------------------------------------------------------------------

--============================================================Sql Project Clean Code===============================================================
--1 
	
select 
Dea.continent,
Dea.location,
Dea.date,
Dea.population,
max(Vac.total_vaccinations) as Rolling_People_Vaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidDeaths$ as Dea
join CovidVaccinations$ as Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null 
group by Dea.continent, Dea.location, Dea.date, Dea.population
order by 1,2,3
---------------------------------------------------------------------------------------
--2
	
--global numbers 
Select 
sum(new_cases) as Total_Cases,
sum(cast(new_deaths as int)) as Total_Deaths,
sum(cast(new_deaths as int)) / sum(new_cases) * 100 as Death_Percentage
From CovidDeaths$
where continent is not null
order by 1,2 
	
--just a double check based off the data provided 
--numbers are extremly close so I will keep them - the second includes "International" location
	
/*    this code has an error I have to handle it later on
Select 
sum(new_cases) as Total_Cases,
sum(cast(new_deaths as int)) as Total_Deaths,
sum(cast(new_deaths as int)) / sum(new_cases) * 100 as Death_Percentage
From CovidDeaths$
--where location like '%states%'
where location = 'World'
group by date 
order by 1,2
*/ 
------------------------------------------------------------------------------------------------------
--3
	
/*I take these out as they are not inluded 
in the above queries and want to stay consistant
European Union is part of Europe*/
	
select
location, 
sum(cast(new_deaths as int)) as Total_Death_Count
from 
CovidDeaths$
--where location like '%Jordan%'
where continent is null 
and location not in ('World','European Union','International')
Group by location
order by Total_Death_Count desc;
	
	
--looking at total cases vs total deaths 
--shows the likelihood of dying in Jordan
Select 
Location,
date, 
total_cases, total_deaths, 
(total_deaths/total_cases) * 100 as Death_Percentage
From CovidDeaths$
where location like 'jordan'
order by 1,2 
-------------------------------------------------------------------------------------------------
--4
	
--looking at countries with highest infection rate compared to population
	
Select 
Location,
population, 
max(total_cases) as Highiest_Infection_Count, 
max((total_cases/population)) * 100 as Percent_Population_Infected
From CovidDeaths$
--where location like 'jordan'
group by location, population
order by Percent_Population_Infected desc;
---------------------------------------------------------------------------
-- 5
	
--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProjects..CovidDeaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2
	
-- took the above query and added population
Select Location, date, population, total_cases, total_deaths
From CovidDeaths$
--Where location like '%states%'
where continent is not null 
order by 1,2
----------------------------------------------------------------------------
--6
	
--use CTE 
with 
Pop_vs_Vac 
(continent, 
location, 
date, 
population,
New_Vaccinations,
Rolling_People_Vaccinated)
as 
(
select
Dea.continent,
Dea.location,
Dea.date,
Dea.population,
Vac.new_vaccinations,
sum(convert(int, Vac.new_vaccinations)) 
over (partition by Dea.location order by Dea.location, Dea.date)
as Rolling_People_Vaccinated
FROM 
CovidDeaths$ as Dea
join 
CovidVaccinations$ as Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3
)
select *, (Rolling_People_Vaccinated / population) * 100 
from 
Pop_vs_Vac;
--------------------------------------------------------------------------------------------
--7
	
Select 
Location, 
Population,
date, 
MAX(total_cases) as Highest_Infection_Count,  
Max((total_cases / population)) * 100 as Percent_Population_Infected
From CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by Percent_Population_Infected desc
---------------------------------------------------------------------------------------------

