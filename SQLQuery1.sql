-- Select the used data

select * from Covid_Portofolio..Covid_Deaths$
where continent is not null
	
select location,date,total_cases,total_deaths,population from Covid_Portofolio..Covid_Deaths$
order by 1,2

--Looking at Total cases vs Total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage 
		from Covid_Portofolio..Covid_Deaths$
		where location like '%Emirates%'
order by 1,2

--Looking at Total cases vs Population
select location, date, population, total_cases, (total_cases/population)*100 AS Cases_Percentage 
		from Covid_Portofolio..Covid_Deaths$
		where location like '%Emirates%'
order by 1,2
select * from Covid_Portofolio..Covid_Deaths$
--Looking at contries with highest infection rate compared to population
select location,population, max(total_cases) As Highest_Infection, max((total_cases/population))*100 AS Highest_infected_population
from Covid_Portofolio..Covid_Deaths$
GROUP BY location, population
ORDER BY Highest_infected_population DESC

--Showing the countries with highest death count per population
select location, population, MAX(CAST(total_deaths AS int)) AS highest_death from Covid_Portofolio..Covid_Deaths$
where continent is not null
Group By location, population
Order BY highest_death DESC

-- Lets break things by the Continent:

select continent, MAX(CAST(total_deaths AS int)) AS highest_death from Covid_Portofolio..Covid_Deaths$
where continent is not null
Group By continent
Order BY highest_death DESC

--Showing the Continent with highest death count per population
select continent, MAX(CAST(total_deaths AS int)) AS highest_death 
from Covid_Portofolio..Covid_Deaths$
where continent is not null
Group By continent
Order BY highest_death DESC

--Global Numbers:

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths) / sum(new_cases)*100 as DeathPercentage
from Covid_Portofolio..Covid_Deaths$
where continent is not null
order by 1,2

-- join the two tables:
-- looking at Total population vs vaccinations
--select * from Covid_Portofolio..Sheet1$
	select dea.continent, dea.location, dea.date, dea.population, 
	vac.new_vaccinations, sum(CONVERT(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
	as Rollingpplvaccination
	--,(Rollingpplvaccination / dea.population)
	from Covid_Portofolio..Covid_Deaths$ dea
	join Covid_Portofolio..Sheet1$ vac
		on dea.location =  vac.location
		and dea.date = vac.date
	where dea.continent is not null
	order by 2,3	

--Use CTE

with PopvsVac (Continent, location , date, population, new_vaccinations, Rollingpplvaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, 
	vac.new_vaccinations, sum(CONVERT(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
	as Rollingpplvaccination
	--,(Rollingpplvaccination / dea.population)
	from Covid_Portofolio..Covid_Deaths$ dea
	join Covid_Portofolio..Sheet1$ vac
		on dea.location =  vac.location
		and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)

SELECT *, 
(Rollingpplvaccination / population )* 100  as PopvesVac
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulatinVaccinated
Create Table #PercentPopulatinVaccinated
( Continent Nvarchar (255),
	Location Nvarchar (255),
	Date datetime,
	population numeric, 
	new_vaccinations numeric,
	Rollingpplvaccinated numeric)

insert into #PercentPopulatinVaccinated
	select dea.continent, dea.location, dea.date, dea.population, 
	vac.new_vaccinations, sum(CONVERT(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
	as Rollingpplvaccination
	--,(Rollingpplvaccination / dea.population)
	from Covid_Portofolio..Covid_Deaths$ dea
	join Covid_Portofolio..Sheet1$ vac
		on dea.location =  vac.location
		and dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3

SELECT *, 
(Rollingpplvaccinated / population )* 100  as PopvesVac
FROM #PercentPopulatinVaccinated


-- CREATE VIEW FOR LATER VISUALIZATION
create view percent_pop_vaccinated 
as
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, sum(CONVERT(float,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
as Rollingpplvaccination
--,(Rollingpplvaccination / dea.population)
from Covid_Portofolio..Covid_Deaths$ dea
join Covid_Portofolio..Sheet1$ vac
		on dea.location =  vac.location
		and dea.date = vac.date
where dea.continent is not null
	--order by 2,3
	
select *  from percent_pop_vaccinated