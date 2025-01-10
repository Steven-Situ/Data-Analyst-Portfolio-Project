-- looking at total cases versus total deaths 
-- shows likelihood of dying if you contract covid in Canada
select ROW_NUMBER() OVER () AS row_num, location, date, total_cases, total_deaths, (total_deaths/total_cases * 100) as DeathPercentage
From portfolioproject.covid_deaths
where location like 'canada'
order by 1,2;


-- looking at total cases versus the population 
-- shows what percentage of population got covid in Canada
select ROW_NUMBER() OVER () AS row_num, location, date, population, total_cases, (total_cases/population * 100) as CasePercentage
From portfolioproject.covid_deaths
where location like 'canada'
order by 1,2;


-- looking at country with highest infection orate compared to population 
select location, population, max(total_cases) as HighestInfectionCount,
Max((total_cases/population * 100)) as PercentPopulationInfected
From portfolioproject.covid_deaths
-- where location like 'canada'
group by location, population
order by PercentPopulationInfected desc;


-- showing countries wiht highest death count per population 
select location, Max(total_deaths) as TotalDeathCount
From portfolioproject.covid_deaths
-- where location like 'canada'
where continent is not null
group by location
order by TotalDeathCount desc;



-- Showing continents with highest deaht count per population 
select location, Max(total_deaths) as TotalDeathCount
From portfolioproject.covid_deaths
-- where location like 'canada'
where continent is null
group by location
order by TotalDeathCount desc;


-- Global
select date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases) * 100 as DeathPercentage
From portfolioproject.covid_deaths
where continent is not null
group by date
order by 1,2;

-- Lookign at total population versus vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVacciated
-- , (RollingPeopleVacciated/population) * 100
from portfolioproject.covid_deaths dea
join portfolioproject.covid_vaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;
    
-- Using CTE
with PopulationsVersusVaccination (continent, location, date, population, new_vaccinations,  RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVacciated
-- , (RollingPeopleVacciated/population) * 100
from portfolioproject.covid_deaths dea
join portfolioproject.covid_vaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *,  (RollingPeopleVaccinated/population) * 100
from PopulationsVersusVaccination;


-- Temp Table
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated (
    continent VARCHAR(255), 
    location varchar(255),
    date datetime, 
    population numeric,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVacciated/population) * 100
from portfolioproject.covid_deaths dea
join portfolioproject.covid_vaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3
;

select *, (RollingPeopleVaccinated/Population) * 100
from PercentPopulationVaccinated;



-- creating view to store data for visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVacciated/population) * 100
from portfolioproject.covid_deaths dea
join portfolioproject.covid_vaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
;

select *
from percentpopulationvaccinated;





