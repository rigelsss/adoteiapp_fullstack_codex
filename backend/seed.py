import sys
import os

sys.path.insert(0, os.path.dirname(__file__))

from app.core.security import hash_text
from app.db.database import Base, SessionLocal, engine
from app.db.models import Interesse, Pet, User

Base.metadata.create_all(bind=engine)

SEED_EMAILS = [
    "seed_ana@adotei.com",
    "seed_carlos@adotei.com",
    "seed_beatriz@adotei.com",
]


def limpar_seed_anterior(db):
    """Remove dados de uma execução anterior do seed para recriá-los do zero."""
    usuarios = db.query(User).filter(User.email.in_(SEED_EMAILS)).all()
    if not usuarios:
        return

    user_ids = [u.id for u in usuarios]
    pet_ids = [p.id for p in db.query(Pet).filter(Pet.dono_id.in_(user_ids)).all()]

    if pet_ids:
        db.query(Interesse).filter(Interesse.pet_id.in_(pet_ids)).delete(synchronize_session=False)
    db.query(Interesse).filter(Interesse.usuario_id.in_(user_ids)).delete(synchronize_session=False)
    db.query(Pet).filter(Pet.dono_id.in_(user_ids)).delete(synchronize_session=False)
    db.query(User).filter(User.id.in_(user_ids)).delete(synchronize_session=False)
    db.commit()


def seed():
    db = SessionLocal()
    limpar_seed_anterior(db)

    # --- Usuários de teste ---
    ana = User(
        nome="Ana", sobrenome="Lima", email="seed_ana@adotei.com",
        senha_hash=hash_text("123456"),
        pergunta_seguranca="Nome do seu primeiro pet?",
        resposta_seguranca_hash=hash_text("rex"),
        cidade="João Pessoa", estado="PB",
    )
    carlos = User(
        nome="Carlos", sobrenome="Souza", email="seed_carlos@adotei.com",
        senha_hash=hash_text("123456"),
        pergunta_seguranca="Cidade onde nasceu?",
        resposta_seguranca_hash=hash_text("recife"),
        cidade="Recife", estado="PE",
    )
    beatriz = User(
        nome="Beatriz", sobrenome="Nunes", email="seed_beatriz@adotei.com",
        senha_hash=hash_text("123456"),
        pergunta_seguranca="Nome da sua escola primária?",
        resposta_seguranca_hash=hash_text("monteiro lobato"),
        cidade="Campina Grande", estado="PB",
    )
    db.add_all([ana, carlos, beatriz])
    db.commit()
    db.refresh(ana)
    db.refresh(carlos)
    db.refresh(beatriz)

    # --- Pets ---
    pets = [
        # João Pessoa, PB — Ana
        Pet(nome="Rex", especie="cão", raca="Labrador", idade=24, porte="grande",
            descricao="Muito dócil e brincalhão. Adora crianças e outros animais. Vacinado e castrado.",
            foto_url="https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=400",
            cidade="João Pessoa", estado="PB", dono_id=ana.id),

        Pet(nome="Bolt", especie="cão", raca="Border Collie", idade=8, porte="médio",
            descricao="Filhote cheio de energia. Precisa de espaço e exercício diário.",
            foto_url="https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=400",
            cidade="João Pessoa", estado="PB", dono_id=ana.id),

        Pet(nome="Thor", especie="cão", raca="Golden Retriever", idade=12, porte="grande",
            descricao="Extremamente dócil. Ótimo com crianças. Já treinado com comandos básicos.",
            foto_url="https://images.unsplash.com/photo-1552053831-71594a27632d?w=400",
            cidade="João Pessoa", estado="PB", dono_id=ana.id),

        Pet(nome="Mimi", especie="gato", raca="Persa", idade=18, porte="pequeno",
            descricao="Calma e carinhosa. Ótima para apartamento. Já usa caixinha de areia.",
            foto_url="https://images.unsplash.com/photo-1535268647677-300dbf3d78d1?w=400",
            cidade="João Pessoa", estado="PB", dono_id=ana.id),

        Pet(nome="Luna", especie="gato", raca="Siamês", idade=36, porte="pequeno",
            descricao="Independente mas muito afetuosa na hora certa. Adora janelas.",
            foto_url="https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400",
            cidade="João Pessoa", estado="PB", dono_id=ana.id),

        Pet(nome="Pipoca", especie="coelho", raca="Mini Rex", idade=6, porte="pequeno",
            descricao="Muito curiosa e sociável. Já acostumada com humanos. Vem com gaiola.",
            foto_url="https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=400",
            cidade="João Pessoa", estado="PB", dono_id=ana.id),

        Pet(nome="Toto", especie="pássaro", raca="Calopsita", idade=24, porte="pequeno",
            descricao="Fala algumas palavras e adora música. Sociável com outros pássaros.",
            foto_url="https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=400",
            cidade="João Pessoa", estado="PB", dono_id=ana.id),

        # Campina Grande, PB — Beatriz
        Pet(nome="Nina", especie="cão", raca="SRD", idade=48, porte="médio",
            descricao="Resgatada da rua. Muito carinhosa e leal. Ama passear.",
            foto_url="https://images.unsplash.com/photo-1601979031925-424e53b6caaa?w=400",
            cidade="Campina Grande", estado="PB", dono_id=beatriz.id),

        Pet(nome="Duque", especie="cão", raca="Beagle", idade=30, porte="médio",
            descricao="Adora farejar e explorar. Ótimo faro. Precisa de quintal.",
            foto_url="https://images.unsplash.com/photo-1608113240010-e76286118bf2?w=400",
            cidade="Campina Grande", estado="PB", dono_id=beatriz.id),

        Pet(nome="Max", especie="cão", raca="Labrador", idade=14, porte="grande",
            descricao="Brincalhão e companheiro, adora água e bolinha. Vacinado e com vermífugo em dia.",
            foto_url="https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=400",
            cidade="Campina Grande", estado="PB", dono_id=beatriz.id),

        Pet(nome="Mel", especie="gato", raca="SRD", idade=10, porte="pequeno",
            descricao="Filhota laranjinha, muito brincalhona. Primeira vacinação feita.",
            foto_url="https://images.unsplash.com/photo-1574144611937-0df059b5ef3e?w=400",
            cidade="Campina Grande", estado="PB", dono_id=beatriz.id),

        Pet(nome="Simba", especie="gato", raca="Maine Coon", idade=14, porte="médio",
            descricao="Grande e peludo, muito manso. Adora colo e não arranha móveis.",
            foto_url="https://images.unsplash.com/photo-1533743983669-94fa5c4338ec?w=400",
            cidade="Campina Grande", estado="PB", dono_id=beatriz.id),

        Pet(nome="Branca", especie="coelho", raca="Angorá", idade=8, porte="pequeno",
            descricao="Pelagem branca e macia. Muito tranquila. Ideal para apartamento.",
            foto_url="https://images.unsplash.com/photo-1643010790410-191ffa19f58e?w=400",
            cidade="Campina Grande", estado="PB", dono_id=beatriz.id),

        Pet(nome="Coco", especie="pássaro", raca="Periquito", idade=12, porte="pequeno",
            descricao="Verde e amarelo, muito alegre. Canta o dia todo. Vem com gaiola.",
            foto_url="https://images.unsplash.com/photo-1560595643-90bb555b2eaa?w=400",
            cidade="Campina Grande", estado="PB", dono_id=beatriz.id),

        # Recife, PE — Carlos
        Pet(nome="Fifi", especie="cão", raca="Poodle", idade=60, porte="pequeno",
            descricao="Dócil e inteligente. Já castrada e com todas as vacinas em dia.",
            foto_url="https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=400",
            cidade="Recife", estado="PE", dono_id=carlos.id),

        Pet(nome="Goku", especie="cão", raca="Shiba Inu", idade=18, porte="médio",
            descricao="Independente e leal. Não se dá muito com estranhos mas ama a família.",
            foto_url="https://images.unsplash.com/photo-1746738771486-72b9347302c4?w=400",
            cidade="Recife", estado="PE", dono_id=carlos.id),

        Pet(nome="Amora", especie="cão", raca="Border Collie", idade=10, porte="médio",
            descricao="Esperta e cheia de energia. Aprende comandos rapidinho. Precisa de espaço para correr.",
            foto_url="https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=400",
            cidade="Recife", estado="PE", dono_id=carlos.id),

        Pet(nome="Lola", especie="gato", raca="Persa", idade=20, porte="pequeno",
            descricao="Tranquila e elegante. Gosta de dormir em lugares altos. Castrada e vacinada.",
            foto_url="https://images.unsplash.com/photo-1535268647677-300dbf3d78d1?w=400",
            cidade="Recife", estado="PE", dono_id=carlos.id),

        Pet(nome="Mingau", especie="gato", raca="SRD", idade=8, porte="pequeno",
            descricao="Gatinho cinza muito brincalhão. Adora se esconder em caixas. Já desverminado.",
            foto_url="https://images.unsplash.com/photo-1574144611937-0df059b5ef3e?w=400",
            cidade="Recife", estado="PE", dono_id=carlos.id),

        Pet(nome="Flor", especie="coelho", raca="Mini Lop", idade=5, porte="pequeno",
            descricao="Filhote dócil, adora carinho atrás das orelhas. Já acostumada com crianças.",
            foto_url="https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?w=400",
            cidade="Recife", estado="PE", dono_id=carlos.id),

        Pet(nome="Piu", especie="pássaro", raca="Calopsita", idade=16, porte="pequeno",
            descricao="Assobia músicas e adora interação. Vem com gaiola e poleiros.",
            foto_url="https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=400",
            cidade="Recife", estado="PE", dono_id=carlos.id),
    ]

    db.add_all(pets)
    db.commit()

    print(f"Seed concluído: 3 usuários e {len(pets)} pets criados.")
    print("Credenciais de teste:")
    print("  seed_ana@adotei.com      / 123456  (João Pessoa, PB)")
    print("  seed_beatriz@adotei.com  / 123456  (Campina Grande, PB)")
    print("  seed_carlos@adotei.com   / 123456  (Recife, PE)")
    db.close()


if __name__ == "__main__":
    seed()
