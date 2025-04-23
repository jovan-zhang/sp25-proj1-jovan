-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0

CREATE VIEW q0(era) AS
 SELECT MAX(era)
 FROM pitching
;


-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT nameFirst, nameLast, birthYear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT nameFirst, nameLast, birthYear
  FROM people
  WHERE nameFirst LIKE '% %'
  ORDER BY nameFirst asc, nameLast asc
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthYear, avg(height), count(*)
  FROM people
  GROUP BY birthyear
  order by birthyear asc
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthYear, avg(height), count(*)
  FROM people
  GROUP BY birthyear
  having avg(height) > 70
  order by birthyear asc
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, p.playerid, yearid
  FROM people p, halloffame h
  where p.playerid = h.playerid and inducted = 'Y'
  order by yearid desc, p.playerid asc
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT nameFirst, namelast, p.playerid, c.schoolid, yearid
  from people p, schools s, halloffame h, collegeplaying c
  where inducted = 'Y' and p.playerid = h.playerid and p.playerid = c.playerid
  and c.schoolid = s.schoolid and schoolstate = 'CA' 
  order by yearid desc, c.schoolid asc, p.playerid asc
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT p.playerid, nameFirst, namelast, c.schoolid
  from halloffame h, people p left join collegeplaying c on p.playerid = c.playerid
  where inducted = 'Y' and p.playerid = h.playerid 
  order by p.playerid desc, c.schoolid asc
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerid, nameFirst, namelast, yearid, ( (H - H2B - H3B - HR) + (2 * H2B) + (3 * H3B) + (4 * HR) )*1.0/AB AS slg
  from people p, batting b
  where AB>50 AND p.playerid = b.playerid
  order by slg desc, yearid asc, p.playerid asc
  limit 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT p.playerid, nameFirst, namelast, ( (sum(h) - sum(H2B) - sum(H3B) - sum(HR)) + (2 * sum(H2B)) + (3 * sum(H3B)) + (4 * sum(HR)) )*1.0/sum(AB) AS lslg
  from people p, batting b
  where p.playerid = b.playerid
  group by p.playerid
  having sum(ab) > 50
  order by lslg desc, p.playerid asc
  limit 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT nameFirst, namelast, ( (sum(h) - sum(H2B) - sum(H3B) - sum(HR)) + (2 * sum(H2B)) + (3 * sum(H3B)) + (4 * sum(HR)) )*1.0/sum(AB) AS lslg
  from people p, batting b
  where p.playerid = b.playerid
  group by p.playerid
  having sum(ab)>50 and ( (sum(h) - sum(H2B) - sum(H3B) - sum(HR)) + (2 * sum(H2B)) + (3 * sum(H3B)) + (4 * sum(HR)) )*1.0/sum(AB) > 
  (select ( (sum(h) - sum(H2B) - sum(H3B) - sum(HR)) + (2 * sum(H2B)) + (3 * sum(H3B)) + (4 * sum(HR)) )*1.0/sum(AB) from batting where playerid = 'mayswi01' group by playerid)

;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  select yearid, min(salary), max(salary), avg(salary)
  from salaries
  group by yearid
  order by yearid asc
;
drop view if exists bin_stats;
-- Question 4ii
CREATE VIEW bin_stats(playerid, salary, binid)
AS
  SELECT playerid, salary,     
    CASE 
        WHEN CAST((salary-507500)/3249250 AS INT) > 9 THEN 9  --binid exceeding 9 are set to 9
        ELSE CAST((salary-507500)/3249250 AS INT)             --else calculated normaly
    END AS binid
  from salaries
  where yearid = 2016 
;

CREATE VIEW q4ii(binid, low, high, count)
AS
  SELECT binid , 507500+binid*3249250.0, 507500+(binid+1)*3249250.0, count(*)
  from bin_stats
  group by binid
  order by binid asc
;

-- Question 4iii

CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  select s1.yearid, s1.min - s2.min, s1.max - s2.max, s1.avg - s2.avg
  from q4i s1, q4i s2
  where s1.yearid-1 = s2.yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT p.playerid, namefirst, namelast, salary, yearid
  from people p, salaries s
  where p.playerid = s.playerid and salary = (select max(salary) from salaries where yearid = 2000) and yearid = 2000
  union
  SELECT p.playerid, namefirst, namelast, salary, yearid
  from people p, salaries s
  where p.playerid = s.playerid and salary = (select max(salary) from salaries where yearid = 2001) and yearid = 2001
;
-- Question 4v

CREATE VIEW q4v(team, diffAvg) AS
  select a.teamid, max(salary) - min(salary) as diffAvg
  from allstarfull a, salaries s
  where a.playerid = s.playerid and a.yearid = s.yearid and a.yearid = 2016
  group by a.teamid
;

