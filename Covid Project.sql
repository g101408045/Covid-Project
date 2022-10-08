Select * from CovidVaccinations where location is null

Select location, date, total_cases, new_cases, total_deaths, population from CovidDeaths order by 1,2

-- Shows likelyhood of dying if we contract Covid in different parts of the world (day to day basis)
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage from CovidDeaths order by 1,2

-- Shows percentage of population got covid in different parts of the world (day to day basis)
Select location, date, population, total_cases, (total_cases/population)*100 as Cases_Percentage from CovidDeaths order by 1,2

-- Shows Countries with Highest infection rate compared to their country's population 
Select location, population, max(total_cases) as Cases_till_now, max(total_cases/population)*100 as infection_rate from CovidDeaths
group by location, population order by infection_rate desc

--Shows Continent with Total Death Count
Select continent, max(cast(total_deaths as int)) as Total_deaths from CovidDeaths group by continent order by Total_deaths desc

-- Showing new cases adding everyday
Select date , sum(new_cases) as Total_new_cases, sum(cast(new_deaths as int)) as Total_new_deaths from CovidDeaths group by date order by date

-- Looking at Population vs Rolling sum cases, Rolling sum Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, sum(isnull(dea.new_cases,0)) over (partition by dea.location order by dea.date ) as Cum_Cases_sum, 
isnull(vac.new_vaccinations,0) as new_vaccinations, sum(cast(isnull(vac.new_vaccinations,0) as bigint)) over (partition by dea.location order by dea.date) as Cum_vacc_sum 
from CovidDeaths dea join CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date

--Use of Common Table Expressions to calculate Cumulative vaccination rate
with CTE1 as(
Select dea.continent, dea.location, dea.date, dea.population, sum(isnull(dea.new_cases,0)) over (partition by dea.location order by dea.date ) as Cum_Cases_sum, 
isnull(vac.new_vaccinations,0) as new_vaccinations, sum(cast(isnull(vac.new_vaccinations,0) as bigint)) over (partition by dea.location order by dea.date) as Cum_vacc_sum 
from CovidDeaths dea join CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date)
Select *, Case when Cum_Cases_sum = 0 then 0
else Cum_vacc_sum/Cum_Cases_sum end as Cum_vaccination_rate from CTE1


--Creating VIEWS

Create view Tot_death_by_cont as
Select continent, max(cast(total_deaths as int)) as Total_deaths from CovidDeaths group by continent
Select* from Tot_death_by_cont

Create view Rolling_sum as
Select dea.continent, dea.location, dea.date, dea.population, sum(isnull(dea.new_cases,0)) over (partition by dea.location order by dea.date ) as Cum_Cases_sum, 
isnull(vac.new_vaccinations,0) as new_vaccinations, sum(cast(isnull(vac.new_vaccinations,0) as bigint)) over (partition by dea.location order by dea.date) as Cum_vacc_sum 
from CovidDeaths dea join CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
Select * from Rolling_sum

--SQL Queries for Power Bi Project

--1.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage From CovidDeaths

--2.
Select continent, SUM(cast(new_deaths as int)) as TotalDeathCount From CovidDeaths group by Continent order by TotalDeathCount desc

--3.
Select Location, isnull(Population,0) as Population, isnull(MAX(total_cases),0) as HighestInfectionCount,  isnull(Max((total_cases/population))*100,0) as PercentPopulationInfected From CovidDeaths
Group by Location, Population order by PercentPopulationInfected desc

--4
Select Location, isnull(Population,0) as Population ,date, isnull(MAX(total_cases),0) as HighestInfectionCount,  isnull(Max((total_cases/population))*100,0) as PercentPopulationInfected
From CovidDeaths Group by Location, Population, date order by PercentPopulationInfected desc
