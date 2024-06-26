spotify <- read.csv("spotify-2023.csv")
library(dplyr)
library(ggplot2)
library(tidyr)
options(scipen = 12)

# Zadanie 1 ---------------------------------------------------------------
# Jak wygląda rozkład liczby odtworzeń piosenek opublikowanych w roku 2023 w pierwszym kwartale 
# w zależności od liczby wykonawców?


df <- spotify %>% 
  filter(released_year==2023, released_month<=3) %>% 
  mutate(streams=as.numeric(streams))
  
ggplot(df, aes(x=as.factor(artist_count), y=streams))+
  geom_boxplot()+
  scale_y_continuous(expand=c(0, 20000000))+
  labs(x="Liczba Artystów", y="Rozkład Liczby Odtworzeń", title="Rozkład liczby odtworzeń piosenek opublikowanych w roku 2023 w pierwszym kwartale w zależności 
od liczby wykonawców")+
  theme_bw()

# Dla każdej z grup mediana odtworzeń jest podobnej wielkości Największą różnicą
# jest to ile dla odpowiednich grup wynosi 3 kwartyl, tzn. dla piosenek
# wydanych przez 2 artystów 3 kwartyl wynosi zdecydowanie więcej niż 3 kwartyl
# dla piosenek wydanych przez 1 lub 3 osoby. Niemniej jednak najczęściej 
# odtwarzany jest utwór wydany przez jedną artystkę - Miley Cyrus - "Flowers".



# Zadanie 2 ---------------------------------------------------------------
# Jak wygląda rozkład liczby wypuszczonych piosenek względem dnia tygodnia dla poszczególnych lat między
# 2019 a 2022?

df <- spotify %>% 
  filter(released_year>=2019, released_year<=2022) %>% 
  mutate(day_of_the_week =weekdays(as.POSIXlt(paste(released_year,"-",released_month,
                                           "-", released_day, sep="")))) %>%
  mutate(day_of_the_week=factor(day_of_the_week, c("poniedziałek", "wtorek",
        "środa", "czwartek", "piątek", "sobota", "niedziela")))%>% 
  group_by(released_year, day_of_the_week) %>% 
  summarise(n=n())



ggplot(df, aes(x=day_of_the_week, y=n))+
  geom_col( fill="magenta")+
  theme_bw()+
  labs(x="Dzień Tygodnia", y="Liczba Piosenek", 
       title="Liczba wypuszczonych piosenek danego dnia tygodnia dla lat 2019-2022")+
  facet_wrap(~released_year, scales = "free_y")

# W każdym roku w latach 2019-2022 zdecydowanie najwięcej utworów jest wydawane
# w piątki.

# Zadanie 3 ---------------------------------------------------------------
# Jaki jest rozkład tempa względem skali ('mode') dla piosenek, które są w 20% 
# najczęściej odtwarzanych piosenek w przeliczeniu na liczbę playlist spotify?


# Nie jestem pewny czy powinienem zająć się liczbą playlist na których pojawiają
# się dane piosenki, czy podzielić liczbę wyświetleń przez liczbę playlist 
# na której odpowiednia piosenka się pojawia. W związku z tym zrobiłem obie wersje. 

df <- spotify %>% 
  filter(in_spotify_playlists >= quantile(in_spotify_playlists, 0.8))


ggplot(df, aes(x=mode, y=bpm))+
  geom_violin(draw_quantiles = c(0.25, 0.5, 0.75))+  
  labs(x="Skala", y="Tempo", title="Rozkład tempa względem skali dla piosenek najczęsciej pojawiających 
się na playlistach spotify ", subtitle= "Liniami zostały zanaczone 1, 2 oraz 3 kwartał")+
  theme_bw()


# W tym przypadku dla obu skali mediana jest podobnej wielkości. Jednakże można
# zauważyć, że rozkład tempa dla skali minor jest bardziej skupiony w okolicach
# mediany niż w przypadku skali major, której rozkład jest bardziej rozproszony.

df1 <- spotify %>% 
  mutate(streams=as.numeric(streams)) %>% 
  mutate(iloraz= ifelse(in_spotify_playlists==0, NaN, streams/in_spotify_playlists)) %>% 
  filter(iloraz >= quantile(iloraz, 0.8))

ggplot(df1, aes(x=mode, y=bpm))+
  geom_violin(draw_quantiles = c(0.25, 0.5, 0.75))+  
  labs(x="Skala", y="Tempo", title="Rozkład tempa względem skali dla piosenek najczęsciej pojawiających 
się na playlistach spotify ", subtitle= "Liniami zostały zanaczone 1, 2 oraz 3 kwartał")+
  theme_bw()

# W tym przypadku rozkład dla obu skali jest bardzo podobny

# Zadanie 4 ---------------------------------------------------------------
# Którzy artyści (osobno) mają najwięcej odtworzeń wszystkich swoich piosenek w sumie (top 10)?

df <- spotify %>%
  filter(artist_count==1) %>% 
  mutate(streams= as.numeric(streams)) %>% 
  group_by(artist.s._name) %>% 
  summarise(suma=sum(streams, na.rm = TRUE)) %>% 
  arrange(-suma) %>% 
  slice(1:10) %>% 
  mutate(artist.s._name= forcats::fct_reorder(artist.s._name, -suma))

ggplot(df, aes(x=artist.s._name, y=suma )) +
  geom_col(fill="violet")+
  labs(x="Artysta", y ="Suma Odtworzeń", title="TOP 10 artystów z najwiekszą sumą odtworzeń swoich piosenek")+
  theme_bw()+
  scale_y_continuous(expand = c(0,0), limits= c(0, 14053658300+1000000000))

# Jak widać najczęściej odwarzanymi artystami są The Weeknd, Taylor Swift 
# oraz Ed Sheeran.



# Zadanie 5 ---------------------------------------------------------------
# Jak zależy energetyczność od tanecznośći patrząc przez pryzmat liczby artystów?


ggplot(spotify, aes(x=danceability_., y=energy_.))+
  geom_point(color="purple")+
  facet_wrap(~artist_count, nrow=2)+
  theme_bw()+
  xlim(0,100)+
  ylim(0,100)+
  labs(x="Taneczność w %", y="Energetyczność w %", 
    title="Zależność energetyczności od taneczności dla danej liczby artystów")

# Dla większej liczby artystów punkty przesuwają się lekko w prawy góny róg,
# co oznacza, że częściej piosenki wydawane przez większą liczbę artystów można 
# opisać jako energetyczne oraz taneczne 


# Zadanie 6 ---------------------------------------------------------------
# Jaka piosenka były najbardziej popularna (liczba odtworzeń) w każdym roku w latach 2013 - 2023?


df <- spotify %>%   filter(released_year>=2013, released_year<=2023) %>% 
  mutate(streams = as.numeric(streams)) %>% 
  arrange(-streams) %>% 
  mutate(released_year=as.character(released_year)) %>% 
  slice_max(order_by=(streams), n=1, by=released_year)

ggplot(df, aes(y= released_year, x=streams))+
  geom_col(fill="green")+
  scale_x_continuous(expand = c(0,0), limits= c(0, 3703895074+100000000))+
  labs(y="Rok Wydania", x="Liczba Odtworzeń", 
       title = "Najbardziej popularna piosenka w danym roku wraz z liczbą odtworzeń")+
  geom_text(aes(x=50000000,label=paste(artist.s._name, "-", track_name)), 
            colour="black",hjust=0, check_overlap = TRUE)+
  theme_bw()

# Wydaję mi się, że komentarz jest tutaj niepotrzebny, co najwyżej możńa zwrócić
# uwagę na to, że najczęściej odtawrzaną piosenką jest "Blinding Lights" -  The Weekend.

# Zadanie 7 ---------------------------------------------------------------
# Jak w 2022 roku wyglądała zależność pomiędzy sumą piosenek na playlistach na spotify a apple patrząc 
# po miesiącach?


df <- spotify %>% 
  filter(released_year==2022) %>%
  mutate(in_spotify_playlists = ifelse(in_spotify_playlists>0,1,0), 
         in_apple_playlists = ifelse(in_apple_playlists>0,1,0)) %>% 
  group_by(released_month) %>% 
  select(released_month ,in_spotify_playlists, in_apple_playlists) %>% 
  rename(Spotify=in_spotify_playlists, Apple=in_apple_playlists) %>% 
  pivot_longer(cols=c(Spotify, Apple)) %>% 
  group_by(released_month,name) %>% 
  summarise(suma=sum(value)) %>% 
  mutate(month=months(as.POSIXlt(paste("2000-",released_month,
                                 "-15", sep="")))) %>% 
  select(-released_month) %>% 
  mutate(month=factor(month, c("styczeń", "luty", "marzec",
"kwiecień", "maj", "czerwiec", "lipiec", "sierpień", "wrzesień", "październik", 
"listopad", "grudzień"))) 


ggplot(df, aes(x=month,y=suma, fill=name))+
  geom_col(position = position_dodge())+
  scale_y_continuous(expand = c(0,0), limits = c(0,80))+
  theme_bw()+
  labs(x="Miesiąc", y="Liczba Piosenek", 
       title="Liczba piosenek pojawiających się na playlistach Apple i Spotify w danych miesiącach w 2022 roku",
  fill="")+
  scale_fill_manual(values = c("black", "green"))
  
# W każdym miesiącu na playlistach Spotify pojawia się  niemniej piosenek niż
# na ploylistach Apple, jednakże różnica, o ile jest, jest znikoma.



