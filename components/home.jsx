
const Main = styled.div`
    background-color: #121216;
    font-size: 16px;
    color: #fff;
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-style: italic;
    font-family: Playfair Display;
    font-weight: 500;
*{
    box-sizing: inherit;
    text-decoration: none;
    list-style: none;
    margin: 0;
    padding: 0;
    color: unset;
    font-family: 'Playfair Display';
}
.section{
    display: flex;
    background-color:#121216;
    align-items: center;
    padding: 3rem;
    border-bottom: 8px groove #ffc4001c;
}

.section:first-child{
    border-bottom: 1rem;
}

.hero{
    display: flex;
    justify-content: space-between;
    padding: 3rem 6rem;
    width: 100%;
    position: relative;
    background: #121216;
    color: #fff;
    align-content: center;
    margin: 0 auto;
    padding: 2rem inherit;
    height: max-content;
}
.heroRight{
    width: 100%;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    position: relative;
    margin-top: -150px;
    padding: 3rem;
}
.heroLeft{
    width: 100%;
    display: flex;
    flex-direction: column;
    justify-content: left;
    align-items: center;
    padding: 2rem 0px;
}

.heroTitle{
    font-size: 34px;
    font-weight: 700;
    line-height: 1.0;
    margin-bottom: 1rem;
}

.heroBody{
    opacity: .7;
}

.heroCTA{
    margin-top: 1rem;
    display: flex;
    justify-content: space-around;
    gap: 1rem;
    width: 100%;
}

.button{
    padding: .5rem 1rem;
    border-radius: 5px;
    border: 1px solid #fff;
    background-color: #121216;
    color: #fff;
    font-size: 21px;
    transition: all .3s ease-in-out;
    box-shadow: 0px 0px 20px rgba(0, 0, 0, 0.415);
    align-items: center;
}

.button:hover{
    background-color: #ADFF2F;;
    color: #000;
}

.sectionTitle{
    font-size: max(1.4rem, 3vw);
    text-align: center;
    /* font-style: normal; */
    font-weight: 700;
}

.create{
    display: flex;
    flex-direction: column;
    padding: 2rem 1rem 2rem 0;
    justify-content: space-around;
}

.createCards{
    display: flex;
    gap: 1rem;
    justify-content: center;
    align-items: center;
    text-align: center;
    margin-top: 2rem;
    padding: 2rem 1rem 2rem 0;
}

.createCards .card{
    background-color: #ADFF2F;
    border-radius: .4rem;
    color: #000;
    border: 2px solid #fff;
    width: 300px;
    height: 400px;
    transition: all .3s ease-in-out;
    display: flex;
    display: -ms-flexbox;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    text-align: center;
}
.createCards .card:hover{
    background-color: #000;
    color: #fff;
    border: 2px solid #ADFF2F;
    cursor: pointer;
}

.createCards .cardTitle{
    font-weight: 1000;
    
    /* font-style: normal; */
    font-size: 1.5rem;
}

@media screen and (max-width: 800px){
    .hero{
        flex-direction: column;
        flex-wrap: nowrap;
        justify-content: center;
        text-align: cleft;
        height: max-content;   
    }
    .heroCTA{
        justify-content: center;
    }
    .cdaoMain_RHS{
        width: 100%;
        position: relative;
    }
}
@media screen and (max-width: 540px){
    .stats{
        flex-direction: column;
    }
    .statSeparator{
        width: 60px;
    height: 2px;
    }
    .heroRight{
        display: none;
    }
    .button{
        font-size: .9rem;
    }
}

`;

const ownerId = state.owner;
return (
  <Main>
    <div class="section hero">
      <div class="heroLeft">
        <h1 class="heroTitle">
          Reinventando las redes profesionales en la era blockchain
        </h1>
        <div class="heroCTA">
          <a href="#" class="button">
            conecta billetera
          </a>
          <a href="" class="button" target="_blank">
            Mostrar balance
          </a>
        </div>
        {/*stats if necessary */}
      </div>
    </div>
    <div class="section create">
      <h2 class="sectionTitle">NFTs</h2>
      <div class="createCards">
        <a href="#" class="card">
          <div class="cardTitle">DashSupreme</div>
          <div class="cardBody">El NFT con mas poder</div>
        </a>
        <a href="#" class="card">
          <div class="cardTitle">NFTverification</div>
          <div class="cardBody">Verifica tu cuenta comprando este nft</div>
        </a>
        <a href="#" class="card">
          <div class="cardTitle">NFT</div>
          <div class="cardBody">Create an NFT</div>
        </a>
      </div>
    </div>
  </Main>
);
