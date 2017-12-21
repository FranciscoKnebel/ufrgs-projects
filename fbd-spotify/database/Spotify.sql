-- Francisco Knebel
-- Mateus Salvi
--
-- 15/12/2017


-- Database Section
-- ________________

create database Spotify;
use Spotify;


-- Tables Section
-- _____________

create table Anunciante (
     id_anunciante int not null,
     nome varchar(50) not null,
     constraint ID_Anunciante_ID primary key (id_anunciante));

create table Concerto (
    id_concerto int not null,
    titulo varchar(60) not null,
    local varchar(60) not null,
    preco decimal(9,2) not null,
    data_e_hora datetime not null,
    id_artista int not null,
    constraint ID_Concerto_ID primary key (id_concerto));

create table Artista (
     id_artista int not null,
     id_radio int,
     biografia varchar(500),
     nome varchar(60) not null,
     constraint ID_Artista_ID primary key (id_artista),
     constraint FKRad_Art_ID unique (id_radio));

create table Album (
    id_album int not null,
    id_radio int,
    titulo varchar(60) not null,
    data_lancamento date not null,
    id_artista int not null,
    constraint ID_Album_ID primary key (id_album),
    constraint FKRad_Alb_ID unique (id_radio));

create table Musica (
    id_musica int not null,
    id_radio int,
    titulo varchar(60) not null,
    duracao int not null,
    contador bigint not null,
    numero int not null,
    id_album int not null,
    constraint ID_Musica_ID primary key (id_musica),
    constraint FKRad_Mus_ID unique (id_radio));

create table Musica_Participacao (
    id_artista int not null,
    id_musica int not null,
    constraint ID_Musica_Participacao_ID primary key (id_musica, id_artista));

create table Reproducao (
     id_usuario int not null,
     data_e_hora datetime not null,
     id_musica int not null,
     constraint ID_Reproducao_ID primary key (id_usuario, data_e_hora, id_musica));

create table Categorizacao (
    id_genero int not null,
    id_album int not null,
    constraint ID_Categorizacao_ID primary key (id_album, id_genero));

create table Genero (
     id_genero int not null,
     id_radio int,
     nome varchar(60) not null,
     constraint ID_Genero_ID primary key (id_genero),
     constraint FKRad_Gen_ID unique (id_radio));

create table Pagamentos (
     data date not null,
     valor decimal(9,2) not null,
     id_usuario int not null);

create table Playlist (
     id_playlist int not null,
     titulo varchar(60) not null,
     constraint ID_Playlist_ID primary key (id_playlist));

create table Playlist_Composicao (
     id_musica int not null,
     id_playlist int not null,
     data_adicao date not null,
     constraint ID_Playlist_Composicao_ID primary key (id_musica, id_playlist));

create table Playlist_Criacao (
     id_playlist int not null,
     id_usuario int not null,
     data_criacao date not null,
     constraint ID_Playlist_Criacao_ID primary key (id_usuario, id_playlist));

create table Playlist_Seguir (
     id_playlist int not null,
     id_usuario int not null,
     data_seguiu date not null,
     constraint ID_Playlist_Seguir_ID primary key (id_usuario, id_playlist));

create table Podcast (
     id_podcast int not null,
     nome varchar(50) not null,
     sobre varchar(300) not null,
     id_artista int not null,
     constraint ID_Podcast_ID primary key (id_podcast));

create table Podcast_Episodio (
     id_episodio int not null,
     nome varchar(100) not null,
     duracao int not null,
     data date not null,
     id_podcast int not null,
     constraint ID_Podcast_Episodio_ID primary key (id_episodio));

create table Propaganda (
     id_propaganda int not null,
     titulo varchar(50) not null,
     duracao bigint not null,
     reproducoes bigint not null,
     investimento decimal(9,2) not null,
     id_anunciante int not null,
     constraint ID_Propaganda_ID primary key (id_propaganda));

create table Radio (
     id_radio int not null,
     titulo varchar(60) not null,
     Album int,
     Musica int,
     Genero int,
     Artista int,
     constraint ID_Radio_ID primary key (id_radio));

create table Radio_Composicao (
     id_musica int not null,
     id_radio int not null,
     data_adicao date not null,
     constraint ID_Radio_Composicao_ID primary key (id_musica, id_radio));

create table Usuario (
     id_usuario int not null,
     nome varchar(60) not null,
     senha varchar(60) not null,
     email varchar(60) not null,
     cidade varchar(60),
     pais char(2),
     inf_nro_cartao char(16),
     inf_data_expiracao char(7),
     inf_cod_seguranca char(3),
     inf_data_renovacao char(2),
     data_criacao date not null,
     tipo int not null,
     constraint ID_Usuario_ID primary key (id_usuario));

create table Video (
     id_video int not null,
     nome varchar(50) not null,
     duracao int not null,
     data_adicao date not null,
     sobre varchar(300),
     id_artista int not null,
     constraint ID_Video_ID primary key (id_video));

-- Constraints Section
-- ___________________

alter table Artista add constraint FKRad_Art_FK
     foreign key (id_radio)
     references Radio (id_radio);

alter table Categorizacao add constraint FKCat_Alb
     foreign key (id_album)
     references Album (id_album);

alter table Categorizacao add constraint FKCat_Gen_FK
     foreign key (id_genero)
     references Genero (id_genero);

alter table Concerto add constraint FKApresentacao_FK
     foreign key (id_artista)
     references Artista (id_artista);

alter table Genero add constraint ID_Genero_CHK
   check(exists(select * from Categorizacao
                where Categorizacao.id_genero = id_genero));

alter table Genero add constraint FKRad_Gen_FK
     foreign key (id_radio)
     references Radio (id_radio);

alter table Musica add constraint ID_Musica_CHK
   check(exists(select * from Musica_Participacao
                where Musica_Participacao.id_musica = id_musica));

alter table Musica add constraint ID_Musica_CHK
   check(exists(select * from Playlist_Composicao
                where Playlist_Composicao.id_musica = id_musica));

alter table Musica add constraint ID_Musica_CHK
   check(exists(select * from Radio_Composicao
                where Radio_Composicao.id_musica = id_musica));

alter table Musica add constraint FKAlbum_Composicao_FK
     foreign key (id_album)
     references Album (id_album);

alter table Musica add constraint FKRad_Mus_FK
     foreign key (id_radio)
     references Radio (id_radio);

alter table Musica_Participacao add constraint FKMus_Mus
     foreign key (id_musica)
     references Musica (id_musica);

alter table Musica_Participacao add constraint FKMus_Art_FK
     foreign key (id_artista)
     references Artista (id_artista);

alter table Pagamentos add constraint FKHistorico_FK
     foreign key (id_usuario)
     references Usuario (id_usuario);

alter table Playlist_Composicao add constraint FKPla_Pla_2_FK
     foreign key (id_playlist)
     references Playlist (id_playlist);

alter table Playlist_Composicao add constraint FKPla_Mus
     foreign key (id_musica)
     references Musica (id_musica);

alter table Playlist_Criacao add constraint FKPla_Usu_1
     foreign key (id_usuario)
     references Usuario (id_usuario);

alter table Playlist_Criacao add constraint FKPla_Pla_1_FK
     foreign key (id_playlist)
     references Playlist (id_playlist);

alter table Playlist_Seguir add constraint FKPla_Usu
     foreign key (id_usuario)
     references Usuario (id_usuario);

alter table Playlist_Seguir add constraint FKPla_Pla_FK
     foreign key (id_playlist)
     references Playlist (id_playlist);

alter table Podcast add constraint ID_Podcast_CHK
   check(exists(select * from Podcast_Episodio
                where Podcast_Episodio.id_podcast = id_podcast));

alter table Podcast add constraint FKPodcast_Producao_FK
     foreign key (id_artista)
     references Artista (id_artista);

alter table Podcast_Episodio add constraint FKPodcast_Composicao_FK
     foreign key (id_podcast)
     references Podcast (id_podcast);

alter table Propaganda add constraint FKPublicacao_FK
     foreign key (id_anunciante)
     references Anunciante (id_anunciante);

alter table Reproducao add constraint FKRep_Usu_FK
     foreign key (id_usuario)
     references Usuario (id_usuario);

alter table Reproducao add constraint FKRep_Mus_FK
     foreign key (id_musica)
     references Musica (id_musica);

alter table Radio add constraint ID_Radio_CHK
   check(exists(select * from Radio_Composicao
                where Radio_Composicao.id_radio = id_radio));

alter table Radio add constraint EXCL_Radio
     check((Album is not null and Artista is null and Genero is null and Musica is null)
           or (Album is null and Artista is not null and Genero is null and Musica is null)
           or (Album is null and Artista is null and Genero is not null and Musica is null)
           or (Album is null and Artista is null and Genero is null and Musica is not null)
           or (Album is null and Artista is null and Genero is null and Musica is null));

alter table Radio_Composicao add constraint FKRad_Rad_FK
     foreign key (id_radio)
     references Radio (id_radio);

alter table Radio_Composicao add constraint FKRad_Mus_1
     foreign key (id_musica)
     references Musica (id_musica);

alter table Usuario add constraint ID_Usuario_CHK
   check(exists(select * from Reproducao
                where Reproducao.id_usuario = id_usuario));

alter table Usuario add constraint COEX_Usuario
     check((inf_nro_cartao is not null and inf_data_expiracao is not null and inf_cod_seguranca is not null and inf_data_renovacao is not null)
           or (inf_nro_cartao is null and inf_data_expiracao is null and inf_cod_seguranca is null and inf_data_renovacao is null));

alter table Video add constraint FKVideo_Producao_FK
     foreign key (id_artista)
     references Artista (id_artista);

alter table Album add constraint ID_Album_CHK
   check(exists(select * from Musica
                where Musica.id_album = id_album));

alter table Album add constraint FKAlbum_Producao_FK
     foreign key (id_artista)
     references Artista (id_artista);

alter table Album add constraint FKRad_Alb_FK
     foreign key (id_radio)
     references Radio (id_radio);


-- Index Section
-- _____________

create unique index ID_Anunciante_IND
     on Anunciante (id_anunciante);

create unique index ID_Artista_IND
     on Artista (id_artista);

create unique index FKRad_Art_IND
     on Artista (id_radio);

create unique index ID_Categorizacao_IND
     on Categorizacao (id_album, id_genero);

create index FKCat_Gen_IND
     on Categorizacao (id_genero);

create unique index ID_Concerto_IND
     on Concerto (id_concerto);

create index FKApresentacao_IND
     on Concerto (id_artista);

create unique index ID_Genero_IND
     on Genero (id_genero);

create unique index FKRad_Gen_IND
     on Genero (id_radio);

create unique index ID_Musica_IND
     on Musica (id_musica);

create index FKAlbum_Composicao_IND
     on Musica (id_album);

create unique index FKRad_Mus_IND
     on Musica (id_radio);

create unique index ID_Musica_Participacao_IND
     on Musica_Participacao (id_musica, id_artista);

create index FKMus_Art_IND
     on Musica_Participacao (id_artista);

create index FKHistorico_IND
     on Pagamentos (id_usuario);

create unique index ID_Playlist_IND
     on Playlist (id_playlist);

create unique index ID_Playlist_Composicao_IND
     on Playlist_Composicao (id_musica, id_playlist);

create index FKPla_Pla_2_IND
     on Playlist_Composicao (id_playlist);

create unique index ID_Playlist_Criacao_IND
     on Playlist_Criacao (id_usuario, id_playlist);

create index FKPla_Pla_1_IND
     on Playlist_Criacao (id_playlist);

create unique index ID_Playlist_Seguir_IND
     on Playlist_Seguir (id_usuario, id_playlist);

create index FKPla_Pla_IND
     on Playlist_Seguir (id_playlist);

create unique index ID_Podcast_IND
     on Podcast (id_podcast);

create index FKPodcast_Producao_IND
     on Podcast (id_artista);

create unique index ID_Podcast_Episodio_IND
     on Podcast_Episodio (id_episodio);

create index FKPodcast_Composicao_IND
     on Podcast_Episodio (id_podcast);

create unique index ID_Propaganda_IND
     on Propaganda (id_propaganda);

create index FKPublicacao_IND
     on Propaganda (id_anunciante);

create unique index ID_Reproducao_ID
     on Reproducao (id_usuario, data_e_hora, id_musica);

create unique index ID_Radio_IND
     on Radio (id_radio);

create unique index ID_Radio_Composicao_IND
     on Radio_Composicao (id_musica, id_radio);

create index FKRad_Rad_IND
     on Radio_Composicao (id_radio);

create unique index ID_Usuario_IND
     on Usuario (id_usuario);

create unique index ID_Video_IND
     on Video (id_video);

create index FKVideo_Producao_IND
     on Video (id_artista);

create unique index ID_Album_IND
     on Album (id_album);

create index FKAlbum_Producao_IND
     on Album (id_artista);

create unique index FKRad_Alb_IND
     on Album (id_radio);

/* Triggers */
CREATE TRIGGER `incrementaContadorMusica`
AFTER INSERT ON `Reproducao`
FOR EACH ROW UPDATE Musica
SET Musica.contador = Musica.contador + 1
WHERE Musica.id_musica = new.id_musica;

CREATE TRIGGER `decrementaContadorMusica`
BEFORE DELETE ON `Reproducao`
FOR EACH ROW UPDATE Musica
SET Musica.contador = Musica.contador - 1
WHERE Musica.id_musica = old.id_musica;
