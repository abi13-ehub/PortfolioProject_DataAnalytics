

Select location, date, total_cases, new_cases, total_deaths, population
from SQLProjects..[ CovidDeaths]
order by 1,2

--looking at the total cases versus the total deaths
-- likelihood of death if you contact covid in India
Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from SQLProjects..[ CovidDeaths]
where location like '%India%'
order by 1,2


-- shows percentage of population having covid

Select location, date, total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
from SQLProjects..[ CovidDeaths]
where continent is not null
--where location like '%India%'
order by 1,2


--looking at countries with highest infection rate compared to Population.

Select location,population,MAX(total_cases) as highestinfectioncount ,MAX((total_cases/population)*100)as PercentPopulationInfected
from SQLProjects..[ CovidDeaths]
where continent is not null
--where location like '%India%'
group by Location,population
order by PercentPopulationInfected desc

--LET'S BREAK THIS DOWN BY CONTINENTS.
-- Showing the countries with the highest Mortality Rate per Population
Select location, MAX(cast(total_deaths as int)) as totaldeathcount 
from SQLProjects..[ CovidDeaths]
where continent is not null
--where location like '%India%'
group by location
order by totaldeathcount  desc


--showing the continents with the highest death count per population.
Select continent, MAX(cast(total_deaths as int)) as totaldeathcount 
from SQLProjects..[ CovidDeaths]
where continent is not null
--where location like '%India%'
group by continent
order by totaldeathcount  desc

-- global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as totaldeathpercentage
from SQLProjects..[ CovidDeaths]
--where location like '%India%'
where continent is not null
--group by date
order by 1,2


select *
from SQLProjects..[ CovidDeaths] death
join SQLProjects..CovidVaccinations vacc
     on death.location = vacc.location
	 and death.date = vacc.date


select death.continent, death.location, death.date,death.population,vacc.new_vaccinations
,SUM(convert(int,vacc.new_vaccinations)) over (partition by vacc.location order by vacc.location,
vacc.date) as RollingPeopleVaccinated

from SQLProjects..[ CovidDeaths] death
join SQLProjects..CovidVaccinations vacc
     on death.location = vacc.location
	 and death.date = vacc.date 
where death.continent is not null and vacc.new_vaccinations is not null
order by 1,2,3,4

-- USE CTE

With PopVsVacc( Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(select death.continent, death.location, death.date,death.population,vacc.new_vaccinations
,SUM(convert(int,vacc.new_vaccinations)) over (partition by death.location order by death.location,
death.date) as RollingPeopleVaccinated

from SQLProjects..[ CovidDeaths] death
join SQLProjects..CovidVaccinations vacc
     on death.location = vacc.location
	 and death.date = vacc.date 
where death.continent is not null --and vacc.new_vaccinations is not null
--order by 1,2,3,4
)
select*, (RollingPeopleVaccinated/Population)*100 -- run this with the cte
from PopVsVacc

-- temp table
Drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #percentpopulationvaccinated
select death.continent, death.location, death.date,death.population,vacc.new_vaccinations
,SUM(convert(int,vacc.new_vaccinations)) over (partition by death.location order by death.location,
death.date) as RollingPeopleVaccinated

from SQLProjects..[ CovidDeaths] death
join SQLProjects..CovidVaccinations vacc
     on death.location = vacc.location
	 and death.date = vacc.date 
--where death.continent is not null --and vacc.new_vaccinations is not null
--order by 1,2,3,4
select*, (RollingPeopleVaccinated/Population)*100 -- run this with the cte
from  #percentpopulationvaccinated






-- creating view to store data for later visualizations
CREATE VIEW PercentPopulation_vaccinated as 
select death.continent, death.location, death.date,death.population,vacc.new_vaccinations
,SUM(convert(int,vacc.new_vaccinations)) over (partition by death.location order by death.location,
death.date) as RollingPeopleVaccinated

from SQLProjects..[ CovidDeaths] death
join SQLProjects..CovidVaccinations vacc
     on death.location = vacc.location
	 and death.date = vacc.date 
where death.continent is not null --and vacc.new_vaccinations is not null



CREATE VIEW PercentPopulation_deaths as 
select death.continent, death.location, death.date,death.population
,SUM(convert(int,death.total_deaths)) over (partition by death.location order by death.location,
death.date) as Totaldeathsviewed

from SQLProjects..[ CovidDeaths] death
join SQLProjects..CovidVaccinations vacc
     on death.location = vacc.location
	 and death.date = vacc.date 
where death.continent is not null 

select *
from PercentPopulation_vaccinated
