import style from '../assets/style/header.module.css';
import logo from '../assets/logo.jpg';
import timeIcon from '../assets/time-icon.jpg';
import { useEffect, useState } from 'react';


interface Time {
    hours:string;
    minutes:string;
    seconds:string;
}

const Header: React.FC = ()=>{
    const [time, setTime] = useState<Time>({
        hours:"",
        minutes:"",
        seconds:""
    });
    useEffect(()=>{
        const interval = setInterval(() => {
            const now = new Date();
            setTime({
                hours: String(now.getHours()).padStart(2,"0"),
                minutes: String(now.getMinutes()).padStart(2,"0"),
                seconds: String(now.getSeconds()).padStart(2,"0")
            })
        }, 1000);
        return ()=> clearInterval(interval);
    },[])
    return(
        <div className={style.header}>
            <div className={style.title}>
                <div className={style.logo}>
                    <img src={logo} alt="logo" />
                </div>
                <div className={style.text}>
                    <h1 className={style.head}>CafeStation Manager</h1>
                    <span className={style.subhead}>playstation cafe management system</span>
                </div>
            </div>
            <div className={style.info}>
                <div className={style.time}><img src={timeIcon} alt="time" />{`${time.hours}:${time.minutes}:${time.seconds}`}</div>
                <div className={style.status}><span className={style.color}></span>System Active</div>
            </div>
        </div>
    )
}

export default Header;