select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--select * from PortfolioProject..CovidVaccination
--order by 3,4

--select  Data that we are going to using
select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases v/s total deaths
-- in this we have find the percentage of deaths of united state.
--showes likelihood of dying if you contracted in your country
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--looking at the total case v/s population
--shows what percentage of population got covid 

select Location,date,population,total_cases,(total_cases/population)*100 as PercentagePopulationInfacted
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


--looking at countries where highest infection rate compared to population

select Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentagePopulationInfacted
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by Location,population
order by PercentagePopulationInfacted DESC
--order by HighestInfectionCount DESC


--showing countries with highest death count per popilation

select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by Location
order by TotalDeathCount DESC

--LET"S BREAK THINGS DOWN BY CONTINENT

--showing continent with highest deaths counts per population  ---  can see the view with this data

select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount DESC

--global numbers -- can see the view with this data

select sum(new_cases) as Total_cases,
sum(cast(new_deaths as int)) as Total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


select * from
PortfolioProject..CovidVaccination


--Looking at total population v/s vaccination
--shows percentage of population that has recived at least one covid vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--dea.new_cases,dea.total_cases,
--sum(convert(int,vac.new_vaccinations)) -->  sum value now has exceeded 2,147,483,647. 
												--So instead of converting it to "int", you will need to convert to "bigint"  next one is imp**
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date ) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3



--using CTE to perform calculation on Partition on by previous query


with popvsvac  (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date ) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select * ,(RollingPeopleVaccinated/population)*100 as PerVaccinatedPopulation
from popvsvac



--Temp Table




drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)



insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date ) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

select * ,(RollingPeopleVaccinated/population)*100 as PerVaccinatedPopulation
from #PercentPopulationVaccinated




--creating view to store data for later visualization


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date ) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3



------
select * from PercentPopulationVaccinated
-----
--drop view if exists PercentPopulationVaccinated

