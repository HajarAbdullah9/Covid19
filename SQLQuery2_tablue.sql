-- SQL Queries for visualization by Tablue:

--1

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths) / sum(new_cases)*100 as DeathPercentage
from Covid_Portofolio..Covid_Deaths$
where continent is not null
order by 1,2

--2
select location, sum(cast(new_deaths as int)) as TotalDeathCount
from Covid_Portofolio..Covid_Deaths$
where continent is null and location not in ('World',
'European Union', 'International','Upper middle income', 'High income', 'Lower middle income','Low income')
group by location 
order by TotalDeathCount desc

--3
select location,population, max(total_cases) As Highest_Infection, max((total_cases/population))*100 AS Highest_infected_population
from Covid_Portofolio..Covid_Deaths$
GROUP BY location, population
ORDER BY Highest_infected_population DESC

--4
--Looking at contries with highest infection rate compared to population

select location,population,date, max(total_cases) As Highest_Infection, max((total_cases/population))*100 AS Highest_infected_population
from Covid_Portofolio..Covid_Deaths$
GROUP BY location, population
ORDER BY Highest_infected_population DESC

--5 
select location,date,population,total_cases,total_deaths 
from Covid_Portofolio..Covid_Deaths$
where continent is not null
order by 1,2

--6
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

--7
select location,population,date, max(total_cases) As Highest_Infection, max((total_cases/population))*100 AS Highest_infected_population
from Covid_Portofolio..Covid_Deaths$
GROUP BY location, population,date
ORDER BY Highest_infected_population DESC

