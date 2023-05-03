--select * from PortfolioProject..CovidDeaths
--order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4


Select location, date, total_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Checking totoal cases vs total deaths

Select location, date, total_cases, total_deaths, (CAST(total_deaths as float)/ CAST(total_cases as float))*100 as DeathPercntage
From PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

-- checking total cases vs population

Select location, date, total_cases, population, (CAST(total_cases as float)/ CAST(population as float))*100 as DeathPercntage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- checking contries with Highest Infection Rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((CAST(total_cases as float)/ CAST(population as float)))*100 as PercntagePopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
Group by location, population
order by PercntagePopulationInfected desc

-- Checking the countries with highest death count per population

Select location, MAX(CAST(total_deaths as INT)) as TotoaldeathsCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location, population
order by TotoaldeathsCount desc

-- Checking the continent with highest death count per population

Select continent, MAX(CAST(total_deaths as INT)) as TotoaldeathsCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotoaldeathsCount desc


-- continent with highest deathrate

Select continent, MAX(CAST(total_deaths as INT)) as TotoaldeathsCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotoaldeathsCount desc


-- Global Number

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
--total_cases, total_deaths, (CAST(total_deaths as float)/ CAST(total_cases as float))*100 as DeathPercntage
From PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
--Group by date
order by 1,2

-- Join Tables

select * 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


-- total population vs vaccination

select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum(convert (float, vac.new_vaccinations)) over(Partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated, 
(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
where dea.continent is not null
and dea.date = vac.date
order by 2,3

-- Use CTE

with popvsvac (Continent, Location, Date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
 select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum(convert (float, vac.new_vaccinations)) over(Partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/population)*100
from popvsvac

-- temp table 

create table #PercentPopulationVaccinated

(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum(convert (float, vac.new_vaccinations)) over(Partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated


-- creating view for data viz

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum(convert (float, vac.new_vaccinations)) over(Partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
