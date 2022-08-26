--select *
--from "CovidVaccinations" cv 
--order by 3,4

--select *
--from "CovidDeaths" cd   
--where continent is notnull 
--order by 3,4

--select data that we are going to be using 
select location, date, total_cases, new_cases, total_deaths, population 
from "CovidDeaths" cd 
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract rona in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases::numeric)*100 as DeathPercentage 
from "CovidDeaths" cd 
where "location" = 'Canada'
order by 1,2

--looking at total cases vs. population
--shows what percentage of pop got rona
select location, date, population, total_cases, (total_cases/population::numeric)*100 as PercentPopulationInfected 
from "CovidDeaths" cd 
where "location" = 'Canada'
order by 1,2  

--looking at countries with highest infection rate compared to population 
select location, population, max(total_cases) as HighestInfectionCount,  Max((total_cases/population::numeric))*100 as PercentPopulationInfected 
from "CovidDeaths" cd 
group by location, population 
order by PercentPopulationInfected desc  

--showing the countries with the highest deathcount/pop
select location, max(total_deaths) as TotalDeathCount 
from "CovidDeaths" cd 
where continent is not null 
group by location 
order by TotalDeathCount desc  

--LETS BREAK THINGS DOWN BY CONTINENT
select continent, max(total_deaths) as TotalDeathCount 
from "CovidDeaths" cd 
where continent is not null 
group by continent  
order by TotalDeathCount desc 

--GLOBAL NUMBERS
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases)::numeric) *100  as DeathPercentage 
from "CovidDeaths" cd 
where  continent is not null 
group by "date" 
order by 1,2

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases)::numeric) *100  as DeathPercentage 
from "CovidDeaths" cd 
where  continent is not null 
order by 1,2

--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population::numeric)*100	
from "CovidDeaths" dea
join "CovidVaccinations" vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 	
order by 2,3

--^^ using cte
with PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)  
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population::numeric)*100
from "CovidDeaths" dea
join "CovidVaccinations" vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 	
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--^^^using temp table
drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated 
(
Continent varchar,
location varchar,
Date date,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinate numeric
)
insert into PercentPopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population::numeric)*100
from "CovidDeaths" dea
join "CovidVaccinations" vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 	
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated


--creating view to store data for later viz'
create view PercentPopulationVaccinated as  
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population::numeric)*100
from "CovidDeaths" dea
join "CovidVaccinations" vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 	
--order by 2,3
